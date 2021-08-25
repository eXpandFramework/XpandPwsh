function Get-ProjectTargetFramework {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [xml]$Project,
        [switch]$FullName
    )
    
    begin {
        
    }
    
    process {
        $targetFramework = $project.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
        if (!$FullName){
            $TargetFramework = "$TargetFramework".Replace("net", "")
        }
        if (!$TargetFramework){
            $targetFramework = $project.Project.PropertyGroup.TargetFrameworkVersion | Where-Object { $_ } | Select-Object -First 1
            if (!$FullName){
                $TargetFramework = $TargetFramework.Replace("v", "").Replace(".","")
            }
        }
        if (!$TargetFramework){
            $targetFramework = ($project.Project.PropertyGroup.TargetFrameworks | Where-Object { $_ } | Select-Object -First 1).Split(';')
        }
        if (!$targetFramework){
            throw "TargetFramework not found"
        }
        $targetFramework
    }
    
    end {
        
    }
}