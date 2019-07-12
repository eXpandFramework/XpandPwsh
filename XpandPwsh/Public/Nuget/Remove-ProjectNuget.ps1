function Remove-ProjectNuget{
    param(
        [parameter(Mandatory)]
        [string]$id,
        [string]$projectPath=(Get-Location),
        [parameter(Mandatory)]
        [string]$nugetAssembliesBin,
        [string]$ProjectFilter="*"
    )
    Get-ChildItem $projectPath "$ProjectFilter.csproj" -Recurse | ForEach-Object { 
        $path=$_.FullName
        [xml]$project=Get-XmlContent $path
        
        if ($project.Project.ItemGroup.packageReference){
            $refNode=($project.Project.ItemGroup.Reference|Select-Object -First 1).ParentNode
            $project.Project.ItemGroup.packageReference|Where-Object{$_.Include -match "$id"}|ForEach-Object{
                $_.ParentNode.RemoveChild($_)
                $r=$project.CreateElement("Reference")    
                $r.SetAttribute("Include",$_.Include)
                $h=$project.CreateElement("HintPath")    
                $h.InnerText="$nugetAssembliesBin\$($_.Include).dll"
                $r.AppendChild($h)
                $refNode.AppendChild($r)
                $project.Save($path)
            }
        }
        else{
            $project.Project.ItemGroup.Reference|Where-Object{$_.Include -match "$id"}|ForEach-Object{
                $fileName=[System.IO.Path]::GetFileName($_.Hintpath)
                $hintPath="$nugetAssembliesBin\$fileName"
                if (!(Test-Path $hintPath)){
                    throw "HintPath not found: $hintPath"
                }
                $_.Hintpath= $hintPath
            }
            $project.Save($path)
        }
        
    } 
    push-location $projectPath
    Clear-ProjectDirectories 
    pop-location
}
