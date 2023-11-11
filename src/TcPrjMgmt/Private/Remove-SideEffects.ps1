function Remove-SideEffects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.__ComObject]
        $DteInstace,

        [Parameter(Mandatory = $true)]
        [string]
        $TmpPath,

        [bool]
        $CloseDteInstance
    )
    
    process {
        Write-Verbose "Cleaning up temporary directory $TmpPath ..."
        $DteInstace.Solution.Close($false)
        Remove-Item $TmpPath -Recurse -Force
        if ($CloseDteInstance) {
            $DteInstace.Quit()
            Stop-MessageFilter
        }
    }
}