function New-DteInstance {
    [CmdletBinding()]
    param (
        [ValidateSet(
            "TcXaeShell.DTE.15.0",
            "VisualStudio.DTE.16.0",
            "VisualStudio.DTE.15.0",
            "VisualStudio.DTE.14.0",
            "VisualStudio.DTE.12.0")]$ForceProgId = $null,
        [switch]$DoNotStartMsgFiltering
    )
    
    if (!$DoNotStartMsgFiltering) {
        Start-MessageFilter
        $msgFilterStarted = $true
    }

    $dte = $null
    $loadedProgId = ""

    Write-Verbose "Trying to create a new DTE instance using known ProgIds"

    if ($ForceProgId) {
        $vsProgIdList = @($ForceProgId) + $ProgIdList
    }
    else {
        $vsProgIdList = $ProgIdList
    }

    foreach ($vsProgId in $vsProgIdList) {
        try {
            $dte = New-Object -ComObject $vsProgId
            $dte.SuppressUI = $true
            $dte.MainWindow.Visible = $false
            $dte.UserControl = $false
            # Check if TwinCAT is integrated with this visual studio version
            $null = $dte.GetObject("TcRemoteManager")
            $loadedProgId = $vsProgId
        }
        catch {
            Write-Debug "Failed to create $vsProgId"
            $dte.Quit()
            $dte = $null
            $loadedProgId = ""
            continue
        }

        break
    }

    if ($dte) {
        Write-Verbose "Successfully created $loadedProgId"
        return $dte
    }

    if ($msgFilterStarted) {
        Start-MessageFilter
    }
    Write-Error "Unable to create a DTE instance"
    return $null
}