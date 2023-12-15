function Export-TcProject {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.__ComObject]
        $DteInstance,

        [Parameter(Mandatory = $true)]
        [string]
        $Solution,

        [Parameter(Mandatory = $true)]
        [string]
        $ProjectName,

        [ValidateSet('Library', 'PlcOpen')]
        [string]
        $Format = 'Library',

        [Parameter(Mandatory = $true)]
        [string]$OutFile
    )

    DynamicParam {
        $attribute = New-Object System.Management.Automation.ParameterAttribute

        switch ($Format) {
            'Library' { 
                $attribute.Mandatory = $false
                $collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $collection.Add($attribute)

                $param = New-Object System.Management.Automation.RuntimeDefinedParameter('InstallUponSave', [bool], $collection) 
            }
            'PlcOpen' { 
                $attribute.Mandatory = $true
                $collection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $collection.Add($attribute)

                $param = New-Object System.Management.Automation.RuntimeDefinedParameter('ExportItems', [string], $collection) 
            }
        }

        $dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $dictionary.Add($param.Name, $param)  

        return $dictionary
    }

    begin {
        $CloseDteInstance = $false

        switch ($Format) {
            'Library' {
                if ($PSBoundParameters.ExportItems) {
                    throw "Given parameter ExportItems is not permitted in $Format export format"
                } 
            }
            'PlcOpen' {
                if ($PSBoundParameters.InstallUponSave) {
                    throw "Given parameter InstallUponSave is not permitted in $Format export format"
                }
            }
        }
    }

    process {
        if (!$DteInstance) {
            Start-MessageFilter
            $DteInstance = New-DteInstance -ErrorAction Stop
            $CloseDteInstance = $true
        }

        $sln = $DteInstance.Solution

        $Solution = Resolve-Path $Solution

        Invoke-CommandWithRetry -ScriptBlock {
            $sln.Open($Solution)
        } -Count 10 -Milliseconds 50 -ErrorAction Stop
    
        $project = Invoke-CommandWithRetry -ScriptBlock {
            $result = $sln.Projects.Item(1)
            if (!$result) {
                throw
            }
    
            return $result
        } -Count 10 -Milliseconds 100 -ErrorAction Stop
    
        $sysMan = Invoke-CommandWithRetry -ScriptBlock {
            $result = $project.Object
            if (!$result) {
                throw
            }
    
            return $result
        } -Count 10 -Milliseconds 100 -ErrorAction Stop
    
        $fullPath = Resolve-OutFile $OutFile
    
        $plc = Invoke-CommandWithRetry -ScriptBlock {
            $result = $sysMan.LookupTreeItem("TIPC^$ProjectName^$ProjectName Project") 
            if (!$result) {
                throw
            }
    
            return , $result
        } -Count 10 -Milliseconds 100 -ErrorAction Stop
    
        switch ($Format) {
            "Library" {
                Invoke-CommandWithRetry -ScriptBlock {
                    $plc.SaveAsLibrary($fullPath, $PSBoundParameters.InstallUponSave)
    
                    if (!(Test-Path $fullPath -PathType Leaf)) { throw }
    
                    Write-Verbose "Saved library successfully"
                } -Count 10 -Milliseconds 100 -Verbose -ErrorAction Stop
            }
    
            "PlcOpen" {
                if ([string]::IsNullOrEmpty($PSBoundParameters.ExportItems)) {
                    Write-Error "Please provide items to be exported semicolon-separated. For example, POUs.FB_MyFunctionBlock1;POUs.MyFunctionBlock2;POUs.MAIN"
                    break;
                }
    
                Invoke-CommandWithRetry -ScriptBlock {
                    $plc.PlcOpenExport($fullPath, $PSBoundParameters.ExportItems)
    
                    if (!(Test-Path $fullPath -PathType Leaf)) { 
                        throw 
                    }
                } -Count 10 -Milliseconds 100 -ErrorAction Stop
            }
        }
    
        if (Test-Path $fullPath -PathType Leaf) {
            Write-Host "$ProjectName exported to $fullPath"
        }
        else {
            Write-Host "Did not save successfully"
        }

        trap {
            Write-Error "$_"
            Remove-SideEffects -DteInstance $DteInstance -TmpPath $TmpPath -CloseDteInstance $CloseDteInstance
            break
        }

        finally {
            Remove-SideEffects -DteInstance $DteInstance -TmpPath $TmpPath -CloseDteInstance $CloseDteInstance
        }
    }
}