. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Get-PlcProjectFile.Tests' {
    Context 'given a path with one PLC project file' {
        It 'should return the expected file' {
            $projectPath = Join-Path -Path $PSScriptRoot -ChildPath "\TestXaeProject\TestXaeProject\TestPlcProject"
            $expected = Join-Path -Path $projectPath -ChildPath "TestPlcProject$global:PlcProjectExtension"

            Get-PlcProjectFile -Path $projectPath | Should -Be $expected
        }
    }

    Context 'given a valid PLC project file' {
        It 'should return the given path' {
            $projectPath = Join-Path -Path $PSScriptRoot -ChildPath "\TestXaeProject\TestXaeProject\TestPlcProject\TestPlcProject.plcproj"
            Get-PlcProjectFile -Path $projectPath | Should -Be $projectPath
        }
    }

    Context 'given a non-existing path' {
        It 'should throw' {
            { Get-PlcProjectFile -Path "Null" } | Should -Throw "Given path does not exist"
        }
    }

    Context 'given a path with no PLC project' {
        BeforeAll {
            $folderName = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())
            New-Item -Type Directory $folderName
        }

        It 'should throw' {
            { Get-PlcProjectFile -Path $folderName } | Should -Throw "Cannot find any $global:PlcProjectExtension in the given path $folderName"
        }

        AfterAll {
            Remove-Item -Recurse -Force -Path $folderName
        }
    }

    Context 'given a path with multiple PLC projects' {
        BeforeAll {
            $folderName = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())
            New-Item -Type Directory $folderName
            $projectFiles = @()
            for ($i = 0; $i -lt 5; $i++) {
                $file = "PlcProjectFile$($i + 1)$global:PlcProjectExtension"
                New-Item -Path $folderName -Type File -Name $file

                $projectFiles += [System.IO.FileInfo](Resolve-Path (Join-Path -Path $folderName -ChildPath $file)).ToString()
            }
        }

        It 'should return an array of projects. If OnlyOne switch is not used' {
            # Using "" to cast array to string to pass Pester comparison. Otherwise test will fail even though two arrays are identical in every way, even the type of their child.
            "$(Get-PlcProjectFile -Path $folderName)" | Should -Be "$projectFiles"
        }

        It 'should throw. If OnlyOne switch is used' {
            { Get-PlcProjectFile -Path $folderName -OnlyOne } | Should -Throw "More than one $global:PlcProjectExtension files found. Please provide the desired $global:PlcProjectExtension explicitly"
        }

        AfterAll {
            Remove-Item -Recurse -Force -Path $folderName
        }
    }
}