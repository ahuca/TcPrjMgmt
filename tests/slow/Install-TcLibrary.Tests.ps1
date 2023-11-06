. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'Install-TcLibrary' {
    BeforeAll {
        $testSolution = $TestXaeSolutionFile
        $testPlcProject = "TestPlcProject"
        $script:installedLibrary = $false

        Start-MessageFilter
        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"

        $outputPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([Guid]::NewGuid())
        New-Item -ItemType Directory -Path $outputPath
        $libraryPath = "$outputPath\$testPlcProject.library"

        $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -OutFile $libraryPath

        $dte.Solution.Close($false)
    }

    It 'should install' {
        Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -PathType Container | Should -Be $false

        $dte | Install-TcLibrary -Path $libraryPath -Force

        Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -PathType Container | Should -Be $true

        $script:installedLibrary = (Get-ChildItem "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -Recurse -Filter "$testPlcProject.library")
        $installedLibrary | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        if ($script:installedLibrary) {
            $dte | Uninstall-TcLibrary -LibName $testPlcProject -LibVersion "*"
        }

        Close-DteInstace $dte
        Stop-MessageFilter
        Remove-Item -Path $outputPath -Recurse
    }
}