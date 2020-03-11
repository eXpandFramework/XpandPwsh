function Switch-DevExpress {
    [alias("Switch-DX")]
    [CmdLetTag()]
    param(
        [parameter(Mandatory)]
        [string]$sourcePath ,
        [parameter( Mandatory)]
        [string]$PackageSource,
        [switch]$SkipPackageDownload
        
    )
    $dxVersion = Get-VersionPart (Get-DevExpressVersion -LatestVersionFeed $PackageSource) Build
    $source = Get-NugetInstallationFolder GlobalPackagesFolder
    if (!$SkipPackageDownload){
        Write-HostFormatted "Download all packages from $PackageSource" -Section
        $packages=Pop-XafPackage -PackageSource $PackageSource 
    }
    else{
        $packages=Get-ChildItem $source DevExpress*$dxVersion.nupkg -Recurse|ConvertTo-PackageObject
    }
    
    $unzipFolder = "$source\..\Unzipped\$((Get-DevExpressVersion $dxVersion ))"
    if ((Test-Path $unzipFolder )) {
        Remove-Item $unzipFolder -Recurse -Force
    }
    New-Item $unzipFolder -Force -ItemType Directory       
    $packages.File | ForEach-Object {
        $id = $_.BaseName
        if (!(Test-Path "$unzipFolder\$id")){
            $zipFile = "$unzipFolder\$id.zip"
            Copy-Item $_.FullName $zipFile -Force
            Expand-Archive $zipFile "$unzipFolder\$id" -Force
            Remove-Item $zipFile
        }
    }    
    
    $assemblies = (@($dxVersion) | ForEach-Object {
            $pversion = "$((Get-DevExpressVersion $_ -Build))"
            [PSCustomObject]@{
                Name       = Get-DevExpressVersion $pversion
                Assemblies = Get-ChildItem $unzipFolder *.dll -Recurse | ConvertTo-Dictionary -KeyPropertyName BaseName -ValueSelector { $_ }
            }        
        }) | ConvertTo-Dictionary -KeyPropertyName name -ValueSelector { $_.Assemblies }
    
    Get-ChildItem $sourcePath *.csproj -Recurse | ForEach-Object {    
        $projectPath = $_.FullName
        [xml]$project = Get-XmlContent $projectPath
        $dxReferences = $project.project.ItemGroup.Reference | Where-Object { $_.Include -like "DevExpress*" }
        if ($dxReferences) {
            Write-HostFormatted "Switching DevExpress to Nugets $projectPath" -Section
            $dxVersion = $dxReferences | ForEach-Object {
                $regex = [regex] '\.v(\d{2}\.\d)'
                $regex.Match($_.Include).Groups[1].Value;
            } | Select-Object -First 1
            $dxReferences | ForEach-Object {
                $_.ParentNode.RemoveChild($_) | Out-Null
                $name = ([regex] '([^,]*)').Match($_.Include).Value
                Write-HostFormatted "Switching $name" -ForegroundColor Magenta
                $package = $assemblies[$dxVersion][$name]
                
                if (!$package) {
                    throw "$name not found in $($projectPath)"
                }
                $parent = $package.Directory.Parent
                do {
                    
                    $packageName = $parent.BaseName  
                    $parent = $parent.Parent  
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

