. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Get-PlcProjectVersion' {
    BeforeAll {
        $TestProjectVersion = [System.Version]::new("0.1.0")
    }

    Context 'given a path with one PLC project file' {
        It 'should return the project version' {
            Get-PlcProjectVersion -Path "$PSScriptRoot\TestXaeProject\TestXaeProject\TestPlcProject" | Should -Be $TestProjectVersion
        }
    }

    Context 'given a PLC project file' {
        It 'should return the project version' {
            Get-PlcProjectVersion -Path "$PSScriptRoot\TestXaeProject\TestXaeProject\TestPlcProject\TestPlcProject.plcproj" | Should -Be $TestProjectVersion
        }
    }
}