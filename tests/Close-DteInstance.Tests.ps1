Import-Module "$PSScriptRoot\..\src\TcPrjMgmt"

Describe 'Close-DteInstance' {
    BeforeAll {
        Start-MessageFilter
        $dte = New-DteInstance
    }

    It 'should close' {
        $dte | Should -Not -Be $null
        $dte | Close-DteInstace
        $dte.PSObject.Properties | ForEach-Object {$_.Value | Should -Be $null}
    }

    AfterAll {
        Stop-MessageFilter
    }
}
