function Remove-SideEffects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.__ComObject]
        $DteInstace,
        
        [bool]
        $CloseDteInstance,

        [Parameter()]
        [string[]]
        $TmpPath
    )
    
    process {
        Write-Verbose "Cleaning up temporary directory $TmpPath ..."
        $DteInstace.Solution.Close($false)
        if ($CloseDteInstance) {
            Invoke-CommandWithRetry -ScriptBlock {
                $DteInstace.Quit()
            } -Count 10 -Milliseconds 200
            Stop-MessageFilter
        }

        foreach ($t in $TmpPath) {
            if (Test-Path $t.ToString() -ErrorAction SilentlyContinue)
            {

            }
            # Remove-Item $t -Recurse -Force
            Write-Host $t
        }
        # if ($TmpPath) {
        #     Remove-Item $TmpPath -Recurse -Force
        # }
    }
}