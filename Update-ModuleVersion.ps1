[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Version
)

$manifestPath = Join-Path -Path $PSScriptRoot -ChildPath '.\src\TcPrjMgmt\TcPrjMgmt.psd1'

Update-ModuleManifest -Path $manifestPath -ModuleVersion $Version
