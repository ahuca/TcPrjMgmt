$DummyProjectPath = (Resolve-Path "$PSScriptRoot\..\Dummy.tpzip").ToString()

function New-DummyTwincatSolution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.__ComObject]
        $DteInstace,

        [Parameter(Mandatory = $true)][string]$Path
    )

    Write-Verbose "Creating a new TwinCAT solution in $Path ..."
    
    $tcProjectTemplatePath = Join-Path -Path $Env:TWINCAT3DIR -ChildPath "\Components\Base\PrjTemplate\TwinCAT Project.tsproj"
    
    if (!(Test-Path $tcProjectTemplatePath -PathType Leaf)) {
        Write-Error "Could not find TwinCAT project template at $tcProjectTemplatePath"
        return $null
    }

    Write-Verbose "... successful"

    $project = Invoke-CommandWithRetry -ScriptBlock {
        $result = $DteInstace.Solution.AddFromTemplate($tcProjectTemplatePath, $Path, "TmpSolution.tsp")
        
        if (!$result) { throw }

        return $result
    } -Count 10 -Milliseconds 200 -ErrorAction Stop

    $systemManager = Invoke-CommandWithRetry -ScriptBlock {
        $result = $project.Object

        if (!$result) { throw }

        return $result
    } -Count 10 -Milliseconds 200 -ErrorAction Stop

    Invoke-CommandWithRetry -ScriptBlock {
        $script:plcTreeItem = $systemManager.LookupTreeItem("TIPC")

        if (!$script:plcTreeItem) { throw }
    } -Count 10 -Milliseconds 200 -ErrorAction Stop

    Write-Verbose "Loading a dummy PLC project from $DummyProjectPath ..."

    $dummyProject = Invoke-CommandWithRetry -ScriptBlock {
        $result = $plcTreeItem.CreateChild("", 0, $null, $DummyProjectPath)

        if (!$result) { throw }

        return $result
    } -Count 10 -Milliseconds 200 -ErrorAction Stop

    if ($dummyProject) {
        Write-Verbose "... successful"
        return $dummyProject
    }
    else {
        Write-Error "... failed"
        return $null
    }
}