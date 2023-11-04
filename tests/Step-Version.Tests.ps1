. "$PSScriptRoot\Setup-TcPrjMgmtTest.ps1"

Describe 'Step-Version' {
    Context 'by Major' {
        It 'should return correct new version' {
            $currentVersion = [System.Version]::new("0.1.0")

            Step-Version -CurrentVersion $currentVersion -By Major | Should -Be ([System.Version]::new("1.1.0"))
        }
    }

    Context 'by Minor' {
        It 'should return correct new version' {
            $currentVersion = [System.Version]::new("0.1.0")

            Step-Version -CurrentVersion $currentVersion -By Minor | Should -Be ([System.Version]::new("0.2.0"))
        }
    }

    Context 'by Build' {
        It 'should return correct new version. If build is used' {
            $currentVersion = [System.Version]::new("0.1.0")

            Step-Version -CurrentVersion $currentVersion -By Build | Should -Be ([System.Version]::new("0.1.1"))
        }

        It 'should throw. If build is not used' {
            $currentVersion = [System.Version]::new("0.1")

            { Step-Version -CurrentVersion $currentVersion -By Build } | Should -Throw -ExpectedMessage "The current version does not use `"Build`""
        }
    }

    Context 'by Revision' {
        It 'should return correct new version. If revision is used' {
            $currentVersion = [System.Version]::new("0.1.0.0")

            Step-Version -CurrentVersion $currentVersion -By Revision | Should -Be ([System.Version]::new("0.1.0.1"))
        }

        It 'should throw. If revision is not used' {
            $currentVersion = [System.Version]::new("0.1.0")

            { Step-Version -CurrentVersion $currentVersion -By Revision } | Should -Throw -ExpectedMessage "The current version does not use `"Revision`""
        }
    }
}