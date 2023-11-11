. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'Install-TcLibrary' {
    BeforeEach {
        $script:installedLibrary = $false

        Start-MessageFilter
        $dte = New-DteInstance -ForceProgId "TcXaeShell.DTE.15.0"

        $libraryPath = $TestPlcLibrary
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

        Close-DteInstace $dte
        Stop-MessageFilter
    }
}