. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'Close-DteInstance' {
    BeforeAll {
        $dte = New-DteInstance
    }

    It 'should close' {
        $dte | Should -Not -Be $null
        $dte | Close-DteInstance
        $dte.PSObject.Properties | ForEach-Object {$_.Value | Should -Be $null}
    }
}
