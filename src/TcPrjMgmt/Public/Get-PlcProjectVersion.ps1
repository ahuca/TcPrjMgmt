function Get-PlcProjectVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Path
    )
    
    process {
        $project = Get-PlcProjectFile $Path -OnlyOne

        [System.Version]$version = (Select-Xml -Path $project -XPath "//Project:ProjectVersion" -Namespace @{'Project' = 'http://schemas.microsoft.com/developer/msbuild/2003' }).Node.InnerText
    }
    
    end {
        return $version
    }
}