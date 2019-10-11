function Remove-ProjectNuget {
    param(
        [parameter(Mandatory)]
        [string]$id,
        [string]$projectPath = (Get-Location),
        [parameter(Mandatory)]
        [string]$nugetAssembliesBin,
        [string]$ProjectFilter = "*",
        [switch]$SkipRestore
    )
    Get-ChildItem $projectPath "$ProjectFilter.csproj" -Recurse | ForEach-Object { 
        $path = $_.FullName
        if(!$SkipRestore){
            dotnet restore $path
        }
        
        [xml]$project = Get-XmlContent $path
        
        if ($project.Project.ItemGroup.packageReference) {
            $refNode = ($project.Project.ItemGroup.Reference | Select-Object -First 1).ParentNode
            $project.Project.ItemGroup.packageReference | Where-Object { $_.Include -match "$id" } | ForEach-Object {
                $_.ParentNode.RemoveChild($_)
                $targetFramework = $project.Project.PropertyGroup.TargetFramework | Where-Object { $_ } | Select-Object -First 1
                FindLibraries $_.Include $_.Version $targetFramework | ForEach-Object {
                    $r = $project.CreateElement("Reference")
                    $r.SetAttribute("Include", $_)
                    $h = $project.CreateElement("HintPath")    
                    $h.InnerText = "$nugetAssembliesBin\$_.dll"
                    $r.AppendChild($h)
                    $refNode.AppendChild($r)
                }
                
                $project.Save($path)
            }
        }
        else {
            $project.Project.ItemGroup.Reference | Where-Object { $_.Include -match "$id" } | ForEach-Object {
                $fileName = [System.IO.Path]::GetFileName($_.Hintpath)
                $hintPath = "$nugetAssembliesBin\$fileName"
                if (!(Test-Path $hintPath)) {
                    throw "HintPath not found: $hintPath"
                }
                $_.Hintpath = $hintPath
            }
            $project.Save($path)
        }
        
    } 
    Push-Location $projectPath
    Clear-ProjectDirectories 
    Pop-Location
}

function FindLibraries {
    param(
        $Id,
        $version,
        $TargetFramework    
    )
    $TargetFramework = $TargetFramework.Replace("net", "")
    $path = "$env:USERPROFILE\.nuget\packages\$id\$version\lib\"
    $item = Get-ChildItem $path | ForEach-Object {
        if ($_.GetType().Name -eq "DirectoryInfo") {
            $_
        }
    } | Sort-Object -Descending | Where-Object {
        $_.BaseName.Replace("net", "") -le $TargetFramework 
    } | Select-Object -First 1
    Push-Location $item.FullName
    Get-ChildItem *.dll | ForEach-Object {
        $_.BaseName
    }
    Pop-Location
}