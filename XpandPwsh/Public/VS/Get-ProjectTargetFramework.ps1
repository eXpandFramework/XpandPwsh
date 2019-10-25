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
        if (!$TargetFramework){
            $targetFramework = $project.Project.PropertyGroup|Where-Object{$_["TargetFrameworkVersion"]}|Select-Object -First 1
        }
        if (!$targetFramework){
            throw "TargetFramework not found"
        }
    }
    
    end {
        
    }
}