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
            Invoke-CommandWithRetry -ScriptBlock {
                $DteInstace.Quit()
            } -Count 10 -Milliseconds 200
            Stop-MessageFilter
        }
    }
}