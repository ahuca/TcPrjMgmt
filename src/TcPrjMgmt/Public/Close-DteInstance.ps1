function Close-DteInstance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$DteInstance,
        [switch]$DoNotStopMsgFiltering
    )
    
    try {
        $DteInstance.Quit()
        if (!$DoNotStopMsgFiltering) {
            Stop-MessageFilter
        }
    }
    catch {}
}