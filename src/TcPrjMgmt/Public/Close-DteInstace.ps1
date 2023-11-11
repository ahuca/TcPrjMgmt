function Close-DteInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$DteInstace,
        [switch]$DoNotStopMsgFiltering
    )
    
    try {
        $DteInstace.Quit()
        if (!$DoNotStopMsgFiltering) {
            Stop-MessageFilter
        }
    }
    catch {}
}