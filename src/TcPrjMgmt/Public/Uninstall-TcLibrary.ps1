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

    begin {
        $CloseDteInstace = $false
    }

    process {
        if (!$DteInstace) {
            Start-MessageFilter
            $DteInstace = New-DteInstance -ErrorAction Stop
            $CloseDteInstace = $true
        }
        
        $dummyPrj = New-DummyTwincatSolution -DteInstace $DteInstace -Path $TmpPath
        
        $systemManager = Invoke-CommandWithRetry -ScriptBlock {
            return $DteInstace.Solution.Projects.Item(1).Object
        } -Count 10 -Milliseconds 100 -ErrorAction Stop

        Invoke-CommandWithRetry -ScriptBlock {
            $script:references = $systemManager.LookupTreeItem("$($dummyPrj[0].PathName)^References")
        } -Count 10 -Milliseconds 100 -ErrorAction Stop

        Write-Host "Uninstalling library $LibName version `"$LibVersion`""

        Invoke-CommandWithRetry -ScriptBlock {
            $references.UninstallLibrary($LibRepo, $LibName, $LibVersion, $Distributor)
        } -Count 10 -Milliseconds 100 -ErrorAction Stop
        
        Write-Host "Successfully uninstalled $LibName version `"$LibVersion`" from $LibRepo"

        trap {
            Write-Error "$_"
            Remove-SideEffects -DteInstace $DteInstace -TmpPath $TmpPath -CloseDteInstance $CloseDteInstace
            break;
        }
    }

    end {
        Remove-SideEffects -DteInstace $DteInstace -TmpPath $TmpPath -CloseDteInstance $CloseDteInstace
    }
}