function Start-MessageFilter {
    [CmdletBinding()]
    param ()
    [MessageFilter]::Register()
}