. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Get-PlcProjectVersion' {
    BeforeAll {
        $TestProjectVersion = [System.Version]::new("0.1.0")
        $PlcProjectExtension = ".plcproj"
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

    Context 'given a non-existing path' {
        It 'should throw' {
            { Get-PlcProjectVersion -Path "Null" } | Should -Throw "Given path does not exist"
        }
    }

    Context 'given a path with no PLC project' {
        BeforeAll {
            $folderName = "$env:TEMP\$(New-Guid)"
            New-Item -Type Directory $folderName
        }

        It 'should throw' {
            { Get-PlcProjectVersion -Path $folderName } | Should -Throw "Cannot find any $PlcProjectExtension in the given path $folderName"
        }

        AfterAll {
            Remove-Item -Recurse -Force -Path $folderName
        }
    }

    Context 'given a path with multiple PLC projects' {
        BeforeAll {
            $folderName = "$env:TEMP\$(New-Guid)"
            New-Item -Type Directory $folderName
            for ($i = 0; $i -lt 5; $i++) {
                New-Item -Path $folderName -Type File -Name "PlcProjectFile$($i + 1)$PlcProjectExtension"
            }
        }

        It 'should throw' {
            { Get-PlcProjectVersion -Path $folderName } | Should -Throw "More than one $PlcProjectExtension files found. Please provide the desired $PlcProjectExtension explicitly"
        }

        AfterAll {
            Remove-Item -Recurse -Force -Path $folderName
        }
    }
}