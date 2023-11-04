. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Step-PlcProjectVersion' {
    BeforeEach {
        $projectFolder = "$env:TEMP\$(New-Guid)"
        New-Item -Type Directory $projectFolder
        $projectFile = "$projectFolder\TestPlcProject$global:PlcProjectExtension"
        New-Item -Type File $projectFile
        Set-Content -Value $global:PlcProjectExampleContent -Path $projectFile
        $currentVersion = Get-PlcProjectVersion -Path $projectFile
    }

    Context 'by Major' {
        It 'should update project file and return the new version' {
            $newVersion = [System.Version]::new("1.1.0")

            Step-PlcProjectVersion -Path $projectFile -By Major

            Get-PlcProjectVersion -Path $projectFile | Should -Be $newVersion
        }
    }

    Context 'by Revision' {
        It 'should throw and does not modify the project file. If project version does not use Revision' {
            { Step-PlcProjectVersion -Path $projectFile -By Revision } | Should -Throw

            Get-PlcProjectVersion -Path $projectFile | Should -Be $currentVersion
        }
    }

    AfterEach {
        Remove-Item $projectFolder -Recurse -Force
    }
}