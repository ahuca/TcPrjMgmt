. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Install-TcLibrary' {
    BeforeAll {
        $testSolution = "$PSScriptRoot\TestXaeProject\TestXaeProject.sln"
        $testPlcProject = "TestPlcProject"
        $script:installedLibrary = $false

        Start-MessageFilter
        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"

        $outputPath = "$Env:TEMP\$([Guid]::NewGuid())"
        New-Item -ItemType Directory -Path $outputPath
        $script:libraryPath = "$outputPath/$testPlcProject.library"

        $dte | Export-TcProject -Solution $testSolution -ProjectName $testPlcProject -Format Library -Path $outputPath

        $dte.Solution.Close($false)
    }

    It 'should install' {
        Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -PathType Container | Should -Be $false

        $dte | Install-TcLibrary -Path $script:libraryPath -Force

        Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -PathType Container | Should -Be $true

        $script:installedLibrary = (Get-ChildItem "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\TestPlcProject" -Recurse -Filter "$testPlcProject.library")
        $script:installedLibrary | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        if ($installedLibrary) {
            $dte | Uninstall-TcLibrary -LibName $testPlcProject -LibVersion "*"
        }

        Close-DteInstace $dte
        Stop-MessageFilter
        Remove-Item -Path $outputPath -Recurse
    }
}