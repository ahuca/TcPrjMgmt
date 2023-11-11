function Uninstall-TcLibrary {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.__ComObject]
        $DteInstace,

        [Parameter(Mandatory = $true)]
        $LibName,

        [string]
        $LibVersion = "*",

        [string]
        $Distributor = $LibName,

        [string]
        $TmpPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid())),

        [string]
        $LibRepo = "System"
    )

    process {
        if (!$DteInstace) {
            $DteInstace = New-DteInstance -ErrorAction Stop
            $CloseDteInstace = $true
            Start-MessageFilter
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

    end {
        if ($CloseDteInstace) {
            $DteInstace.Quit()
            Stop-MessageFilter
        }
    }
}