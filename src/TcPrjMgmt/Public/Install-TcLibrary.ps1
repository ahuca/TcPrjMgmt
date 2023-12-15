function Install-TcLibrary {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.__ComObject]
        $DteInstance,

        [Parameter(Mandatory = $true)]
        $Path,
        
        [string]
        $TmpPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid())),
        
        [string]
        $LibRepo = "System",

        [switch]$Force
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
    
            if (!(Test-Path $Path -PathType Leaf)) {
                throw "Provided library path $Path does not exist"
            }
            
            $dummyPrj = New-DummyTwincatSolution -DteInstance $DteInstance -Path $TmpPath
        
            try {
                $systemManager = $DteInstance.Solution.Projects.Item(1).Object
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