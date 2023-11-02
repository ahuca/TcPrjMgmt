function Stop-MessageFilter {
    [CmdletBinding()]
    param ()
    [MessageFilter]::Revoke()
}