function Remove-SideEffects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.__ComObject]
        $DteInstance,
        
        [bool]
        $CloseDteInstance,

        [Parameter()]
        [string[]]
        $TmpPath
    )
    
    process {
        Write-Verbose "Cleaning up temporary directory $TmpPath ..."
        $DteInstance.Solution.Close($false)
        if ($CloseDteInstance) {
            Invoke-CommandWithRetry -ScriptBlock {
                $DteInstance.Quit()
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