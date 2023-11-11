function Invoke-CommandWithRetry {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Script block to be executed")][scriptblock]$ScriptBlock,
        [Parameter(Position = 1, HelpMessage = "Number of times to retry")][int]$Count = 5,
        [Parameter(Position = 2, HelpMessage = "Time delay between retries")][int]$Milliseconds = 100
    )

    Begin {
        $failures = 0
    }

    Process {
        do {
            try {
                return $ScriptBlock.Invoke()
            }
            catch {
                $failures++
                Start-Sleep -Milliseconds $Milliseconds
            }
        } while ($failures -lt $Count)

        if ($failures -eq $Count) {
            Write-Error "Maximum amount of retries ($Count) have been reached"
        }
    }
}