function Step-Version {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.Version]$CurrentVersion,
        [ValidateSet("Major", "Minor", "Build", "Revision")][Parameter(Mandatory = $true)][string]$By
    )
    
    process {
        if ($CurrentVersion."$By" -eq -1) {
            throw "The current version does not use `"$By`""
        }

        $versionParts = @("Major", "Minor", "Build", "Revision")

        foreach ($part in $versionParts) {
            if ($By -eq $part) {
                Set-Variable -Name $part -Value ($CurrentVersion.$part + 1)
            }
            else {
                Set-Variable -Name $part -Value $CurrentVersion.$part
            }
        }

        $newVersion = ""
        foreach ($part in $versionParts) {
            $partValue = [int](Get-Variable -Name $part).Value

            if ($partValue -gt -1) {
                if ($newVersion) {
                    $newVersion += "."
                }

                $newVersion += $partValue.ToString()
            }
        }
    }
    
    end {
        return [System.Version]::new($newVersion)
    }
}