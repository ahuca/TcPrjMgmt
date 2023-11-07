function Step-PlcProjectVersion {
    [CmdletBinding()]
    param (
        [ValidateSet("Major", "Minor", "Build", "Revision")][Parameter(Mandatory = $true)][string]$By,
        [Parameter(Mandatory = $true)][string]$Path
    )
    
    process {
        $project = Get-PlcProjectFile $Path -OnlyOne

        $xmlDoc = New-Object -TypeName xml
        $xmlDoc.Load($project)

        $currentVersion = [System.Version]::new($xmlDoc.Project.PropertyGroup.ProjectVersion.ToString())

        $newVersion = Step-Version $currentVersion -By $By

        $xmlDoc.Project.PropertyGroup.ProjectVersion = $newVersion.ToString()
        $xmlDoc.Save($project)
    }
    
    end {
        return [System.Version]::new($newVersion)
    }
}