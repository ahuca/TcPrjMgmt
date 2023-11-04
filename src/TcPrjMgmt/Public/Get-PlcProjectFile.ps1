function Assert-FlatProjectFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Path
    )

    return ((Split-Path $Path -Extension) -eq $PlcProjectExtension)
}

function Get-PlcProjectFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Path,
        [switch]$OnlyOne
    )
    
    process {
        if (!(Test-Path $Path)) {
            throw "Given path does not exist"
        }

        if (Assert-FlatProjectFile $Path) {
            Write-Verbose "A PLC project file has been given"
            $ret = $Path
            return $ret
        }

        Write-Verbose "A path has been given, looking for PLC project files under the path"
        $ret = Get-ChildItem -Path "$Path\*$PlcProjectExtension" -Recurse

        if (($ret -is [System.Array]) -and $OnlyOne) {
            throw "More than one $PlcProjectExtension files found. Please provide the desired $PlcProjectExtension explicitly"
        }

        if (!$ret) {
            throw "Cannot find any $PlcProjectExtension in the given path $Path"
        }

        return $ret
    }
}