function Get-ProjectTargetFramework {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [xml]$Project
    )
    
    begin {
        
    }
    
    process {
        $targetFramework = $project.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
        $TargetFramework = "$TargetFramework".Replace("net", "")
        if (!$TargetFramework){
            $targetFramework = $project.Project.PropertyGroup.TargetFrameworkVersion | Where-Object { $_ } | Select-Object -First 1
            $TargetFramework = $TargetFramework.Replace("v", "").Replace(".","")
        }
        if (!$targetFramework){
            throw "TargetFramework not found"
        }
        $targetFramework
    }
    
    end {
        
    }
}