. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Update-PlcPrjVersion' {
    BeforeEach {
        $projectFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid())
        New-Item -Type Directory $projectFolder
        $projectFile = Join-Path -Path $projectFolder -ChildPath "\TestPlcProject$global:PlcProjectExtension"
        New-Item -Type File $projectFile
        Set-Content -Value $global:PlcProjectExampleContent -Path $projectFile
        $currentVersion = Get-PlcProjectVersion -Path $projectFile
    }

    It 'should update to the requested version' {
        $newVersion = [System.Version]::new("10.0.0")

        Update-PlcProjectVersion -Path $projectFile -Version $newVersion

        $newVersion | Should -Not -Be $currentVersion
        Get-PlcProjectVersion -Path $projectFile | Should -Be $newVersion
    }

    AfterEach {
        Remove-Item $projectFolder -Recurse -Force
    }
}