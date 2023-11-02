function Resolve-OutFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $OutFile
    )

    if (Split-Path -Path $OutFile -IsAbsolute) {
        return $OutFile
    }
    else {
        $parent = Split-Path -Path $OutFile
        if (!$parent) { $parent = $PWD }
        $leaf = Split-Path -Path $OutFile -Leaf
        $fullPath = "$(Resolve-Path $parent)\$($leaf)"

        return $fullPath
    }

}