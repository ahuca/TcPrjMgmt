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