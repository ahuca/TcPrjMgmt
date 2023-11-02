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