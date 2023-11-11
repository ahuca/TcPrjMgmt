. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'Uninstall-TcLibrary' {
    BeforeEach {
        Install-TcLibrary -Path $TestPlcLibraryPath -Force
    }

    # We only test without a DTE instance because, Uninstall-TcLibrary is also "tested" implicitly in Install-TcLibrary.Tests.ps1
    It 'should uninstall library' {
        Uninstall-TcLibrary -LibName $TestPlcProject -LibVersion "*"
    }
}