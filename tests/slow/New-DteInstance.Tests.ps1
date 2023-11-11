. "$PSScriptRoot\..\Setup-TcPrjMgmtTest.ps1"

Describe 'New-DteInstance' {
    BeforeAll {
        Start-MessageFilter
    }

    Context 'with forced ProgId' {
        It 'Should create a new instance with correct version' {
            $versions = @("TcXaeShell.DTE.15.0")
    
            foreach ($v in $versions) {
                $dte = New-DteInstance $v

                if ($v.Split(".")[0] -eq "VisualStudio") {
                    $dte.Name | Should -Be "Microsoft Visual Studio"
                }
                else {
                    $dte.Name | Should -Be $v.Split(".")[0]
                }
    
                $dte.Version | Should -Be ($v.Split(".")[2..3] -join ".")
                
                Close-DteInstance $dte
            }
        }
    }

    Context 'with no parameters' {
        BeforeAll {
            $global:dte = New-DteInstance
        }

        It 'Should create TcXaeShell.DTE.15.0 by default' {
            $dte.Name | Should -Be "TcXaeShell"
            $dte.Version | Should -Be "15.0"
        }

        AfterAll {
            $dte | Close-DteInstance
        }
    }

    AfterAll {
        Stop-MessageFilter
    }
}
