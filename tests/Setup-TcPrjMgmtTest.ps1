function Import-ModuleUnderTest {
    [CmdletBinding]

    Import-Module "$PSScriptRoot\..\src\TcPrjMgmt"
}

Import-ModuleUnderTest
