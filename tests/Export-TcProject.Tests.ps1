Import-Module "$PSScriptRoot\..\TcPrjMgmt"

Describe 'Export-TcProject' {
    BeforeAll {
        $testSolution = ".\TestXaeProject\TestXaeProject.sln"
        $testPlcProject = "TestPlcProject"
        Start-MessageFilter
        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"
    }

    Context 'as a library' {
        It 'given a specific path. Should save to given path' {
            $outputPath = "$Env:TEMP\$([Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = "$outputPath/$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -Path $outputPath

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            $outputFile = "$PWD\$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputFile
        }
    }

    Context 'as PLCOpen' {
        It 'given a specific path. Should save to given path' {
            $outputPath = "$Env:TEMP\$([Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = "$outputPath/$testPlcProject.xml"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -Path $outputPath

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            $outputFile = "$PWD/$testPlcProject.xml"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs"

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputFile
        }
    }

    AfterAll {
        Close-DteInstace $dte
        Stop-MessageFilter
    }
}