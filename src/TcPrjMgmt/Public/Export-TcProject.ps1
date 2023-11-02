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

                Write-Verbose "Saved library successfully"
            } -Count 10 -Milliseconds 100 -Verbose
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
    else {
        Write-Host "Did not save successfully"
    }

    $DteInstace.Solution.Close($false)
}