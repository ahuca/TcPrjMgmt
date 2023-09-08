. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Export-TcProject' {
    BeforeAll {
        $global:testSolution = "$PSScriptRoot\TestXaeProject\TestXaeProject.sln"
        $global:testPlcProject = "TestPlcProject"
        Start-MessageFilter
        $global:dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"
    }

    Context 'as a library' {
        It 'given a specific path. Should save to given path' {
            $outputPath = "$Env:TEMP\$([Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = "$outputPath/$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile $outputFile

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            $outputFile = "$PWD\$testPlcProject.library"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile "$testPlcProject.library"

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputFile
        }
    }

    Context 'as PLCOpen' {
        It 'given a specific path. Should save to given path' {
            $outputPath = "$Env:TEMP\$([Guid]::NewGuid())"
            New-Item -ItemType Directory -Path $outputPath
            $outputFile = "$outputPath/$testPlcProject.xml"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -OutFile $outputFile

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputPath -Recurse
        }

        It 'without any path. Should save to working directory' {
            $outputFile = "$PWD/$testPlcProject.xml"

            $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format PlcOpen -ExportItems "POUs" -OutFile "$testPlcProject.xml"

            Test-Path $outputFile | Should -BeTrue
            Remove-Item -Path $outputFile
        }
    }

    AfterAll {
        Close-DteInstace $dte
        Stop-MessageFilter
    }
}