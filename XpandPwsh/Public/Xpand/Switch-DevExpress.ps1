function Switch-DevExpress {
    [alias("Switch-DX")]
    param(
        [string[]]$dxNugetPackagesPath ,
        [parameter(Mandatory)]
        [string]$sourcePath 
        
    )
    $dxPath = Get-DevExpressPath
    if (!$dxNugetPackagesPath) {
        [hashtable]$dxNugetPackagesPath = $dxPath | ForEach-Object { 
            [PSCustomObject]@{
                Name = $_.Name
                Path="$($_.Directory)\System\Components\packages" 
            }
        }|ConvertTo-Dictionary -KeyPropertyName name -ValueSelector {$_.Path}
    }
    $dxNugetPackagesPath.Keys | ForEach-Object {
        if (!(Test-Path "$_\Nupkg")) {
            New-Item "$_\Nupkg" -ItemType Directory -ErrorAction SilentlyContinue
            Get-ChildItem $_ *.nupkg | ForEach-Object {
                if (!(Test-Path "$_\Nupkg\$($_.BaseName).zip")) {
                    $zipFile = "$($_.DirectoryName)\Nupkg\$($_.BaseName).zip"
                    Copy-Item $_.FullName $zipFile
                    Expand-Archive $zipFile "$($_.DirectoryName)\Nupkg\$($_.BaseName)"
                    Remove-Item $zipFile
                }
            }
        }
    }
    
    $dxNugetPackagesPath=$dxNugetPackagesPath.Keys | foreach-Object { 
        $path=$dxNugetPackagesPath[$_]
        [PSCustomObject]@{
            Name=$_
            Assemblies=(Get-ChildItem "$path\Nupkg\" "*.dll" -Recurse)|ConvertTo-Dictionary -KeyPropertyName BaseName -ValueSelector {$_}
        }
     }|ConvertTo-Dictionary -KeyPropertyName Name -ValueSelector{$_.Assemblies}
    
    Get-ChildItem $sourcePath *.csproj -Recurse | ForEach-Object {    
        $projectPath = $_.FullName
        [xml]$project = Get-XmlContent $projectPath
        $dxReferences = $project.project.ItemGroup.Reference | Where-Object { $_.Include -like "DevExpress*" }
        if ($dxReferences) {
            Write-HostFormatted "Switching $projectPath" -fg Magenta
            $dxVersion=$dxReferences|ForEach-Object{
                $regex = [regex] '\.v(\d{2}\.\d)'
                $regex.Match($_.Include).Groups[1].Value;
            }|Select-Object -First 1
            $dxReferences | ForEach-Object {
                $_.ParentNode.RemoveChild($_) | Out-Null
                $name = ([regex] '([^,]*)').Match($_.Include).Value
                
                $package = $dxNugetPackagesPath[$dxVersion][$name]
                
                if (!$package) {
                    throw "$name not found in $($projectPath)"
                }
                $packageName = (Get-Item "$($package.DirectoryName)\..\..\").BaseName
                $regex = [regex] '(?ix)\.[\d]*\.[\d]*\.[\d]*'
                $Version = $regex.Match($packageName).Value.Trim(".")
                $packageName = $regex.Replace($packageName, "")
                
                Add-XmlElement $project PackageReference ItemGroup ([ordered]@{
                    Include = $packageName
                    Version = $version
                })
            }
            $project.Save($projectPath)
            $projectPath | Remove-BlankLines
            Write-HostFormatted "Saved $projectPath" -ForegroundColor Green
        }
    }
}
