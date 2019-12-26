function Switch-DevExpress {
    [alias("Switch-DX")]
    param(
        [parameter()]
        [string[]]$dxNugetPackagesPath ,
        [parameter(Mandatory)]
        [string]$sourcePath 
        
    )
    $dxPath = Get-DevExpressPath -ErrorAction SilentlyContinue
    if (!$dxNugetPackagesPath) {
        [hashtable]$dxNugetPackagesPath = $dxPath | ForEach-Object { 
            [PSCustomObject]@{
                Name = $_.Name
                Path="$($_.Directory)\System\Components\packages" 
            }
        }|ConvertTo-Dictionary -KeyPropertyName name -ValueSelector {$_.Path}
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
        $assemblies=$dxNugetPackagesPath.Keys | foreach-Object { 
            $path=$dxNugetPackagesPath[$_]
            [PSCustomObject]@{
                Name=$_
                Assemblies=(Get-ChildItem "$path\Nupkg\" "*.dll" -Recurse)|ConvertTo-Dictionary -KeyPropertyName BaseName -ValueSelector {$_}
            }
         }|ConvertTo-Dictionary -KeyPropertyName Name -ValueSelector{$_.Assemblies}
    }
    else{
        $source=($dxNugetPackagesPath|Select-Object -First 1)
        $assemblies=(Get-LatestMinorVersion -id DevExpress.ExpressApp -top 100 -Source $source|ForEach-Object{
            $pversion="$((Get-DevExpressVersion $_ -Build))"
            $unzipFolder="$dxNugetPackagesPath\Unzipped\$((Get-DevExpressVersion $_ ))"
            if (!(Test-Path $unzipFolder )){
                New-Item $unzipFolder -Force -ItemType Directory
                Get-ChildItem $dxNugetPackagesPath "*$pVersion*"|ForEach-Object{
                    $id=$_.BaseName
                    $zipFile="$unzipFolder\$id.zip"
                    Copy-Item $_.FullName $zipFile -Force
                    Expand-Archive $zipFile "$unzipFolder\$id" -Force
                    Remove-Item $zipFile
                }    
            }
            [PSCustomObject]@{
                Name = Get-DevExpressVersion $pversion
                Assemblies=Get-ChildItem $unzipFolder *.dll -Recurse|ConvertTo-Dictionary -KeyPropertyName BaseName -ValueSelector {$_}
            }
            
        })|ConvertTo-Dictionary -KeyPropertyName name -ValueSelector {$_.Assemblies}
    }
    
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
                
                $package = $assemblies[$dxVersion][$name]
                
                if (!$package) {
                    throw "$name not found in $($projectPath)"
                }
                $parent=$package.Directory.Parent
                do {
                    
                    $packageName=$parent.BaseName  
                    $parent=$parent.Parent  
                } until ($parent.BaseName -eq $dxVersion)
                
                
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

