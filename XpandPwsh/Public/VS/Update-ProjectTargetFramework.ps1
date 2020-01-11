function Update-ProjectTargetFramework {
    [CmdletBinding()]
    param (
        [ValidateSet("4.5.2","4.6.1","4.7.1","4.7.2","4.8")]
        $FrameworkVersion="4.6.1"
    )
    
    begin {
    }
    
    process {
        $allProjects=Get-Project -All
        $allProjects
        $activity="Changing TargetFramework to $FrameworkVersion"
        $activity
        $allProjects|ForEach-Object{
            $projectName=$_.ProjectName
            [xml]$csproj=Get-Content $_.FullName
            $csproj.Project.PropertyGroup|Where-Object{$_["TargetFrameworkVersion"]}|ForEach-Object{
                "Changing $projectName $($_.TargetFrameworkVersion) to $FrameWorkVersion"
                $_.TargetFrameworkVersion="v$FrameworkVersion"
            }
            $csproj.Save($_.FullName)
        }
    }
    
    end {
    }
}