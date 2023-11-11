. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

# Due to the facts that,
# - Both these functions (Install-TcLibrary and Uninstall-TcLibrary) have side effects,
# - We only use one single test library (tests\TestXaeProject\TestPlcProject.library) for testing these functions
# We must combine the tests of these two functions so they can run sequentially without interfering each others.

Describe 'Install-TcLibrary' {
    BeforeEach {
        $script:installedLibrary = $false

        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"

        $libraryPath = $TestPlcLibraryPath
    }

    Context 'given a DTE instance' {
        It 'should install' {
            Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -PathType Container | Should -Be $false
    
            $dte | Install-TcLibrary -Path $libraryPath -Force
    
            Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -PathType Container | Should -Be $true
    
            $script:installedLibrary = (Get-ChildItem "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -Recurse -Filter "$TestPlcProject.library")
            $script:installedLibrary | Should -Not -BeNullOrEmpty
        }
    }

    Context 'without a DTE instance' {
        It 'should install' {
            Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -PathType Container | Should -Be $false
    
            Install-TcLibrary -Path $libraryPath -Force
    
            Test-Path "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -PathType Container | Should -Be $true

            $script:installedLibrary = (Get-ChildItem "$Env:TWINCAT3DIR\Components\Plc\Managed Libraries\$TestPlcProject" -Recurse -Filter "$TestPlcProject.library")
            $script:installedLibrary | Should -Not -BeNullOrEmpty
        }
    }

    AfterEach {
        if ($script:installedLibrary) {
            $dte | Uninstall-TcLibrary -LibName $TestPlcProject -LibVersion "*"
        }

        Close-DteInstance $dte
    }
}

Describe 'Uninstall-TcLibrary' {
    BeforeEach {
        Install-TcLibrary -Path $TestPlcLibraryPath -Force
    }

    # We only test without a DTE instance because, Uninstall-TcLibrary is also "tested" implicitly in Install-TcLibrary.Tests.ps1
    It 'should uninstall library' {
        Uninstall-TcLibrary -LibName $TestPlcProject -LibVersion "*"
    }
}
