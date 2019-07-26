function Switch-DevExpress {
    [alias("Switch-DX")]
    param(
        [parameter(Mandatory)]
        [string[]]$dxNugetPackagesPath ,
        [parameter(Mandatory)]
        [string]$sourcePath 
        
    )
    New-Item "$dxNugetPackagesPath\Nupkg" -ItemType Directory -ErrorAction SilentlyContinue
    Get-ChildItem $dxNugetPackagesPath *.nupkg|ForEach-Object{
        if (!(Test-Path "$dxNugetPackagesPath\Nupkg\$($_.BaseName).zip")){
            Copy-Item $_.FullName "$dxNugetPackagesPath\Nupkg\$($_.BaseName).zip"
            Expand-Archive "$dxNugetPackagesPath\Nupkg\$($_.BaseName).zip" "$dxNugetPackagesPath\Nupkg\$($_.BaseName)"
            Remove-Item "$dxNugetPackagesPath\Nupkg\$($_.BaseName).zip"
        }
    }
    
    Get-ChildItem $sourcePath *.csproj -Recurse | ForEach-Object {
        $projectPath=$_.FullName
        [xml]$project = Get-XmlContent $projectPath
        $dxReferences = $project.project.ItemGroup.Reference | Where-Object{$_.Include -like "DevExpress*"}
        if ($dxReferences) {
            $packageReferences = $project.project.ItemGroup.PackageReference|Where-Object{$_}
            if (!$packageReferences) {
                $group = $project.CreateElement("ItemGroup")
                $project.project.AppendChild($group)|Out-Null
            }
            else{
                $group=$packageReferences.ParentNode
            }
            $dxReferences |ForEach-Object {
                $_.ParentNode.RemoveChild($_)|Out-Null
                $name=$_.Include
                $package=get-childItem "$dxNugetPackagesPath\Nupkg\" "$name.dll" -Recurse|Select-Object -First 1
                
                if (!$package){
                    throw "$name not found in $($projectPath)"
                }
                $packageName=(Get-Item "$($package.DirectoryName)\..\..\").BaseName
                $regex=[regex] '(?ix)\.[\d]*\.[\d]*\.[\d]*'
                $Version=$regex.Match($packageName).Value.Trim(".")
                $packageName=$regex.Replace($packageName,"")
                $packageReference = $project.CreateElement("PackageReference")
                $packageReference.SetAttribute("Include",$packageName)
                $packageReference.SetAttribute("Version",$Version)
                $group.AppendChild($project.CreateTextNode([System.Environment]::NewLine))|Out-Null
                $group.AppendChild($project.CreateTextNode("    "))|Out-Null
                $group.AppendChild($packageReference)|Out-Null
                $group.AppendChild($project.CreateTextNode([System.Environment]::NewLine))|Out-Null
                $projectPath|Remove-BlankLines
            }
            $project.Save($projectPath)
            "Saved $projectPath"
        }
    }
}
