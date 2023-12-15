function Uninstall-TcLibrary {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.__ComObject]
        $DteInstance,

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

    begin {
        $CloseDteInstance = $false
    }

    process {
        try {
            if (!$DteInstance) {
                Start-MessageFilter
                $DteInstance = New-DteInstance -ErrorAction Stop
                $CloseDteInstance = $true
            }
            
            $dummyPrj = New-DummyTwincatSolution -DteInstance $DteInstance -Path $TmpPath
            
            $systemManager = Invoke-CommandWithRetry -ScriptBlock {
                return $DteInstance.Solution.Projects.Item(1).Object
            } -Count 10 -Milliseconds 100 -ErrorAction Stop
    
            Invoke-CommandWithRetry -ScriptBlock {
                $script:references = $systemManager.LookupTreeItem("$($dummyPrj[0].PathName)^References")
            } -Count 10 -Milliseconds 100 -ErrorAction Stop
    
            Write-Host "Uninstalling library $LibName version `"$LibVersion`""
    
            Invoke-CommandWithRetry -ScriptBlock {
                $references.UninstallLibrary($LibRepo, $LibName, $LibVersion, $Distributor)
            } -Count 10 -Milliseconds 100 -ErrorAction Stop
            
            Write-Host "Successfully uninstalled $LibName version `"$LibVersion`" from $LibRepo"
        }
        finally {
            Remove-SideEffects -DteInstance $DteInstance -TmpPath $TmpPath -CloseDteInstance $CloseDteInstance
        }

        trap {
            Write-Error "$_"
            Remove-SideEffects -DteInstance $DteInstance -TmpPath $TmpPath -CloseDteInstance $CloseDteInstance
            break;
        }
    }
}