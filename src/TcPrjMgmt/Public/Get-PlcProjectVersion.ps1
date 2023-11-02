function Assert-FlatProjectFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Path
    )

    return ((Split-Path $Path -Extension) -eq $PlcProjectExtension)
}

function Get-PlcProjectVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Path
    )
    
    process {
        if (!(Test-Path $Path)) {
            throw "Given path does not exist"
        }

        if (Assert-FlatProjectFile $Path) {
            Write-Verbose "A PLC project file has been given"
            $project = $Path
        }
        else {
            Write-Verbose "A path has been given, looking for a PLC project file under the path"
            $project = Get-ChildItem -Path "$Path\*$PlcProjectExtension" -Recurse
        }

        if ($project -is [System.Array]) {
            throw "More than one $PlcProjectExtension files found. Please provide the desired $PlcProjectExtension explicitly"
        }

        if (!$project) {
            throw "Cannot find any $PlcProjectExtension in the given path $Path"
        }

        [System.Version]$version = (Select-Xml -Path $project -XPath "//Project:ProjectVersion" -Namespace @{'Project' = 'http://schemas.microsoft.com/developer/msbuild/2003' }).Node.InnerText
    }
    
    end {
        return $version
    }
}