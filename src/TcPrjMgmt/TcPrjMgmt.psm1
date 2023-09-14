$MsgFilterSrc = @"
// https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2010/ms228772(v=vs.100)

using System;
using System.Runtime.InteropServices;

public class MessageFilter : IOleMessageFilter
{
    //
    // IOleMessageFilter functions.
    // Handle incoming thread requests.
    int IOleMessageFilter.HandleInComingCall(int dwCallType,
        IntPtr hTaskCaller, int dwTickCount, IntPtr
            lpInterfaceInfo)
    {
        //Return the flag SERVERCALL_ISHANDLED.
        return 0;
    }

    // Thread call was rejected, so try again.
    int IOleMessageFilter.RetryRejectedCall(IntPtr
        hTaskCallee, int dwTickCount, int dwRejectType)
    {
        if (dwRejectType == 2)
            // flag = SERVERCALL_RETRYLATER.
            // Retry the thread call immediately if return >=0 & 
            // <100.
            return 99;
        // Too busy; cancel call.
        return -1;
    }

    int IOleMessageFilter.MessagePending(IntPtr hTaskCallee,
        int dwTickCount, int dwPendingType)
    {
        //Return the flag PENDINGMSG_WAITDEFPROCESS.
        return 2;
    }
    // Class containing the IOleMessageFilter
    // thread error-handling functions.

    // Start the filter.
    public static void Register()
    {
        IOleMessageFilter newFilter = new MessageFilter();
        IOleMessageFilter oldFilter = null;
        CoRegisterMessageFilter(newFilter, out oldFilter);
    }

    // Done with the filter, close it.
    public static void Revoke()
    {
        IOleMessageFilter oldFilter = null;
        CoRegisterMessageFilter(null, out oldFilter);
    }

    // Implement the IOleMessageFilter interface.
    [DllImport("Ole32.dll")]
    private static extern int
        CoRegisterMessageFilter(IOleMessageFilter newFilter, out
            IOleMessageFilter oldFilter);
}

[ComImport]
[Guid("00000016-0000-0000-C000-000000000046")]
[InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IOleMessageFilter
{
    [PreserveSig]
    int HandleInComingCall(
        int dwCallType,
        IntPtr hTaskCaller,
        int dwTickCount,
        IntPtr lpInterfaceInfo);

    [PreserveSig]
    int RetryRejectedCall(
        IntPtr hTaskCallee,
        int dwTickCount,
        int dwRejectType);

    [PreserveSig]
    int MessagePending(
        IntPtr hTaskCallee,
        int dwTickCount,
        int dwPendingType);
}
"@

Add-Type -TypeDefinition $MsgFilterSrc

Set-Variable -Name "ProgIdList" -Scope global -Option Constant -Value @(
    "TcXaeShell.DTE.15.0", # TcXaeShell (VS2017)
    "VisualStudio.DTE.16.0", # VS2019
    "VisualStudio.DTE.15.0", # VS2017
    "VisualStudio.DTE.14.0", # VS2015
    "VisualStudio.DTE.12.0" # VS2013
)

$DummyProjectPath = (Resolve-Path "$PSScriptRoot\Dummy.tpzip").ToString()

function Start-MessageFilter {
    [CmdletBinding()]
    param ()
    [MessageFilter]::Register()
}

function Stop-MessageFilter {
    [CmdletBinding()]
    param ()
    [MessageFilter]::Revoke()
}

function Invoke-CommandWithRetry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Script block to be executed")][scriptblock]$ScriptBlock,
        [Parameter(Position = 1, HelpMessage = "Number of times to retry")][int]$Count = 5,
        [Parameter(Position = 2, HelpMessage = "Time delay between retries")][int]$Milliseconds = 100
    )

    Begin {
        $failures = 0
    }

    Process {
        do {
            try {
                $ScriptBlock.Invoke()
                break
            }
            catch {
                $failures++
                Start-Sleep -Milliseconds $Milliseconds
            }
        } while ($failures -lt $Count)

        if ($failures -eq $Count) {
            Write-Error "Maximum amount of retries ($Count) have been reached"
        }
    }
}

function New-DteInstance {
    [CmdletBinding()]
    param (
        [ValidateSet(
            "TcXaeShell.DTE.15.0",
            "VisualStudio.DTE.16.0",
            "VisualStudio.DTE.15.0",
            "VisualStudio.DTE.14.0",
            "VisualStudio.DTE.12.0")]$ForceProgId = $null
    )

    $dte = $null
    $loadedProgId = ""

    Write-Verbose "Trying to create a new DTE instance using known ProgIds"

    if ($ForceProgId) {
        $vsProgIdList = @($ForceProgId) + $ProgIdList
    }
    else {
        $vsProgIdList = $ProgIdList
    }

    foreach ($vsProgId in $vsProgIdList) {
        try {
            $dte = New-Object -ComObject $vsProgId
            $dte.SuppressUI = $true
            $dte.MainWindow.Visible = $false
            $dte.UserControl = $false
            # Check if TwinCAT is integrated with this visual studio version
            $null = $dte.GetObject("TcRemoteManager")
            $loadedProgId = $vsProgId
        }
        catch {
            Write-Debug "Failed to create $vsProgId"
            $dte.Quit()
            $dte = $null
            $loadedProgId = ""
            continue
        }

        break
    }

    if ($dte) {
        Write-Verbose "Successfully created $loadedProgId"
        return $dte
    }

    Write-Error "Unable to create a DTE instace"
    return $null
}

function Close-DteInstace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$DteInstace
    )
    
    try {
        $DteInstace.Quit()
    }
    catch {}
}

function Resolve-OutFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $OutFile
    )

    if (Split-Path -Path $OutFile -IsAbsolute) {
        return $OutFile
    }
    else {
        $parent = Split-Path -Path $OutFile
        if (!$parent) { $parent = $PWD }
        $leaf = Split-Path -Path $OutFile -Leaf
        $fullPath = "$(Resolve-Path $parent)\$($leaf)"

        return $fullPath
    }

}


function Export-TcProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.__ComObject]$DteInstace,
        [Parameter(Mandatory = $true)][string]$Solution,
        [Parameter(Mandatory = $true)][string]$ProjectName,
        [ValidateSet("Library", "PlcOpen")][string]$Format = "Library",
        [Parameter(Mandatory = $true)][string]$OutFile,
        [Parameter(HelpMessage = "Only used if export format is Library")][switch]$InstallUponSave = $false,
        [Parameter(HelpMessage = "Only used if export format is PlcOpen")][string]$ExportItems = ""
    )

    $sln = $DteInstace.Solution

    $Solution = Resolve-Path $Solution
    try {
        $sln.Open($Solution)
    }
    catch {
        Write-Error "Could not open $Solution"
        return
    }

    $project = Invoke-CommandWithRetry -ScriptBlock {
        $project = $sln.Projects.Item(1)
        if (!$project) {
            throw
        }

        return $project
    } -Count 10 -Milliseconds 100

    $sysMan = Invoke-CommandWithRetry -ScriptBlock {
        $sysMan = $project.Object
        if (!$sysMan) {
            throw
        }

        return $sysMan
    } -Count 10 -Milliseconds 100

    try {
        $fullPath = Resolve-OutFile $OutFile
    }
    catch {
        Write-Error $_
        $DteInstace.Solution.Close($false)
    }

    $plc = Invoke-CommandWithRetry -ScriptBlock {
        $result = $sysMan.LookupTreeItem("TIPC^$ProjectName^$ProjectName Project") 
        if (!$result) {
            throw
        }

        return , $result
    } -Count 10 -Milliseconds 100

    switch ($Format) {
        "Library" {
            
            Invoke-CommandWithRetry -ScriptBlock {
                $plc.SaveAsLibrary($fullPath, $InstallUponSave)

                if (!(Test-Path $fullPath -PathType Leaf)) { throw }
            } -Count 10 -Milliseconds 100
        }

        "PlcOpen" {
            if ([string]::IsNullOrEmpty($ExportItems)) {
                Write-Error "Please provide items to be exported semicolon-separated. For example, POUs.FB_MyFunctionBlock1;POUs.MyFunctionBlock2;POUs.MAIN"
                break;
            }

            Invoke-CommandWithRetry -ScriptBlock {
                $plc.PlcOpenExport($fullPath, $ExportItems)

                if (!(Test-Path $fullPath -PathType Leaf)) { throw }
            } -Count 10 -Milliseconds 100
        }
    }

    if (Test-Path $fullPath -PathType Leaf) {
        Write-Host "$ProjectName exported to $fullPath"
    }

    $DteInstace.Solution.Close($false)
}

function New-DummyTwincatSolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.__ComObject]$DteInstace,
        [string]$Path = "$Env:TEMP\$([Guid]::NewGuid())"
    )

    Write-Verbose "Creating a new TwinCAT solution in $Path ..."
    
    $tcProjectTemplatePath = "$Env:TWINCAT3DIR\Components\Base\PrjTemplate\TwinCAT Project.tsproj"
    
    if (!(Test-Path $tcProjectTemplatePath -PathType Leaf)) {
        Write-Error "Could not find TwinCAT project template at $tcProjectTemplatePath"
        return $null
    }

    Write-Verbose "... successful"

    $project = $DteInstace.Solution.AddFromTemplate($tcProjectTemplatePath, $Path, "TmpSolution.tsp")
    $systemManager = $project.Object
    $plc = $systemManager.LookupTreeItem("TIPC")
    
    Write-Verbose "Loading a dummy PLC project from $DummyProjectPath ..."
    $dummyProject = $plc.CreateChild("", 0, $null, $DummyProjectPath)

    if ($dummyProject) {
        Write-Verbose "... successful"
        return $dummyProject
    }
    else {
        Write-Error "... failed"
        return $null
    }
}

function Install-TcLibrary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.__ComObject]$DteInstace,
        [Parameter(Mandatory = $true)]$Path,
        [string]$TmpPath = "$Env:TEMP\$([Guid]::NewGuid())",
        [string]$LibRepo = "System",
        [switch]$Force
    )

    if (!(Test-Path $Path -PathType Leaf)) {
        throw "Provided library path $Path does not exist"
    }
    
    if (!$DteInstace) {
        throw "No DTE instance provided, or it is null"
    }
    
    $dummyPrj = New-DummyTwincatSolution -DteInstace $DteInstace -Path $TmpPath

    try {
        $systemManager = $DteInstace.Solution.Projects.Item(1).Object
    }
    catch {
        throw "Failed to get the system manager object"
    }
    
    try {
        $references = $systemManager.LookupTreeItem("$($dummyPrj[0].PathName)^References")
    }
    catch {
        throw "Failed to look up the project references"
    }
    
    Write-Host "Installing library $Path to $LibRepo"
    
    if ($Force) { $forceInstall = $true }
    else { $forceInstall = $false }
        
    Write-Host "Forced installation set to ``$forceInstall``"
    
    try {
        $references.InstallLibrary($LibRepo, $Path, $forceInstall)
    }
    catch {
        throw "Failed to install $Path to $LibRepo"
    }

    Write-Host "Successfully installed $Path to $LibRepo"

    trap {
        Write-Error "$_"
        Write-Verbose "Cleaning up temporary directory $TmpPath ..."
        $DteInstace.Solution.Close($false)
        Remove-Item $TmpPath -Recurse -Force
    }

    Write-Verbose "Cleaning up temporary directory $TmpPath ..."
    $DteInstace.Solution.Close($false)
    Remove-Item $TmpPath -Recurse -Force
}

function Uninstall-TcLibrary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.__ComObject]$DteInstace,
        [Parameter(Mandatory = $true)]$LibName,
        [string]$LibVersion = "*",
        [string]$Distributor = $LibName,
        [string]$TmpPath = "$Env:TEMP\$([Guid]::NewGuid())",
        [string]$LibRepo = "System"
    )

    if (!$DteInstace) {
        Write-Error $_
        throw "No DTE instance provided, or it is null"
    }
    
    $dummyPrj = New-DummyTwincatSolution -DteInstace $DteInstace -Path $TmpPath
    
    try {
        $systemManager = $DteInstace.Solution.Projects.Item(1).Object
    }
    catch {
        throw "Failed to get the system manager object"
    }
    
    try {
        $references = $systemManager.LookupTreeItem("$($dummyPrj[0].PathName)^References")
        $references = $systemManager.LookupTreeItem("$($dummyPrj[0].PathName)^References")
    }
    catch {
        throw "Failed to look up the project references"
    }
    
    Write-Host "Uninstalling library $LibName version `"$LibVersion`""
    
    try {
        $references.UninstallLibrary($LibRepo, $LibName, $LibVersion, $Distributor)
    }
    catch {
        throw "Failed to uninstall $LibName $LibVersion from $LibRepo"
    }
    
    Write-Host "Successfully uninstalled $LibName version `"$LibVersion`" from $LibRepo"

    trap {
        Write-Error "$_"
        Write-Verbose "Cleaning up temporary directory $TmpPath ..."
        $DteInstace.Solution.Close($false)
        Remove-Item $TmpPath -Recurse -Force
    }

    Write-Verbose "Cleaning up temporary directory $TmpPath ..."
    $DteInstace.Solution.Close($false)
    Remove-Item $TmpPath -Recurse -Force
}
