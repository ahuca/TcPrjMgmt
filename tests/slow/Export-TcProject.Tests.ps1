. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'Export-TcProject' {
    BeforeAll {
        $testSolution = $TestXaeSolutionFile
        $testPlcProject = "TestPlcProject"
        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"
    }

    Context 'as a library' {
        It 'given a specific path. Should save to given path' {
            $outputPath = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())path
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = Join-Path -Path $outputPath -ChildPath "$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile $outputFile

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            $outputFile = Join-Path -Path $PWD -ChildPath "$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile "$testPlcProject.library"

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputFile
        }

        It 'using incorrect parameter. Should throw' {
            { $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile "$testPlcProject.library" -ExportItems "FOO" } | Should -Throw
        }
    }

    Context 'as PLCOpen' {
        It 'given a specific path. Should save to given path' {
            $outputPath = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = Join-Path -Path $outputPath -ChildPath "$testPlcProject.xml"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -OutFile $outputFile

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            Invoke-Command -ScriptBlock {
                $outputPath = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())
                New-Item -Type Directory $outputPath
                Set-Location -Path $outputPath
                Write-Host $PWD
                $outputFile = Join-Path -Path $outputPath -ChildPath "$testPlcProject.xml"

                $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -OutFile "$testPlcProject.xml"

                Test-Path $outputFile | Should -BeTrue
                Remove-Item -Path $outputFile
            }
        }

        It 'using incorrect parameter. Should throw' {
            { $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -OutFile "$testPlcProject.xml" -InstallUponSave } | Should -Throw
        }
    }

    Context 'without a DTE instance' {
        It 'should self service own instance' {
            $outputPath = Join-Path -Path $TestDrive -ChildPath ([Guid]::NewGuid())path
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = Join-Path -Path $outputPath -ChildPath "$testPlcProject.library"

            Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile $outputFile

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }
    }

    AfterAll {
        Close-DteInstance $dte
    }
}