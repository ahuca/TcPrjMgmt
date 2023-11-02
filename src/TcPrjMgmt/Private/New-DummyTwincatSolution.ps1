$DummyProjectPath = (Resolve-Path "$PSScriptRoot\..\Dummy.tpzip").ToString()

function New-DummyTwincatSolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.__ComObject]$DteInstace,
        [string]$Path = "$Env:TEMP\$([Guid]::NewGuid())"
    )

    Write-Verbose "Creating a new TwinCAT solution in $Path ..."
    
    $tcProjectTemplatePath = "$Env:TWINCAT3DIR\Components\Base\PrjTemplate\TwinCAT Project.tsproj"
    
    if (!(Test-Path $tcProjectTemplatePath -PathType Leaf)) {
        Write-Error "Could not find TwinCAT project template at $tcProjectTemplatePath"
        return $null
    }

    Write-Verbose "... successful"

    $project = $DteInstace.Solution.AddFromTemplate($tcProjectTemplatePath, $Path, "TmpSolution.tsp")
    $systemManager = $project.Object
    $plc = $systemManager.LookupTreeItem("TIPC")
    
    Write-Verbose "Loading a dummy PLC project from $DummyProjectPath ..."
    $dummyProject = $plc.CreateChild("", 0, $null, $DummyProjectPath)

    if ($dummyProject) {
        Write-Verbose "... successful"
        return $dummyProject
    }
    else {
        Write-Error "... failed"
        return $null
    }
}