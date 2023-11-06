$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "\src\TcPrjMgmt"
$publicFolder = Join-Path -Path $modulePath -ChildPath "\Public"
$manifestFile = Join-Path -Path $modulePath -ChildPath "TcPrjMgmt.psd1"

$publicScripts = (Get-ChildItem -Path $publicFolder | Select-Object Name).Name

$functionsToExport = ($publicScripts | ForEach-Object {$_.ToString()})

Update-ModuleManifest -Path $manifestFile -FunctionsToExport $functionsToExport