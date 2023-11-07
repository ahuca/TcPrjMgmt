function Update-PlcProjectVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Version
    )
    
    process {
        $project = Get-PlcProjectFile $Path -OnlyOne
        $xmlDoc = New-Object -TypeName xml
        $xmlDoc.Load($project)

        $xmlDoc.Project.PropertyGroup.ProjectVersion = $Version.ToString()

        $xmlDoc.Save($project)
    }
}