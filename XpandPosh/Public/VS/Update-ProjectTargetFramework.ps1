function Update-ProjectTargetFramework {
    [CmdletBinding()]
    param (
        [ValidateSet("4.5.2","4.6.1","4.7.1")]
        $FrameworkVersion="4.6.1"
    )
    
    begin {
    }
    
    process {
        $allProjects=Get-Project -All
        $activity="Changing TargetFramework to $FrameworkVersion"
        $activity
        $allProjects|Invoke-Parallel -ActivityName $activity -VariablesToImport "FrameworkVersion" -Script {
            "Changing $($_.Name)"
            ($_.Properties|Where-Object{$_.Name -match "TargetFrameworkMoniker"}).Value=".NETFramework,Version=v$FrameworkVersion"
        }
    }
    
    end {
    }
}