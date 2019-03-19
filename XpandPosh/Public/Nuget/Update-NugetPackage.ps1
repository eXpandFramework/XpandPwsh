function Update-NugetPackage{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$SourcePath=".",
        [parameter()]
        [string]$Filter="*"
    )
    $configs=Get-ChildItem $sourcePath packages.config -Recurse|ForEach-Object{
        [PSCustomObject]@{
            Content = [xml]$(Get-Content $_.FullName)
            Config = $_
        }
    }
    $configs.Content.Packages.package.id
    $sources=Get-PackageSourceLocations Nuget
    $ids=$configs|ForEach-Object{$_.Content.packages.package.id}|Where-Object{$_ -like $Filter}|Select-Object -Unique 
    $metadatas= $ids|Invoke-Parallel -activityName "Getting latest versions from sources" -Script {(Get-NugetPackageSearchMetadata -Name $_ -Sources $Using:sources)}
    $packages=$configs|ForEach-Object{
        $config=$_.Config
        $_.Content.packages.package|Where-Object{$_.id -like $filter}|ForEach-Object{
            $packageId=$_.Id
            $metadata=$metadatas|Where-object{$_.Metadata.Identity.id -eq $packageId}
            if ($metadata){
                [PSCustomObject]@{
                    Id = $packageId
                    NewVersion = (Get-MetadataVersion $metadata.Metadata).Version
                    Config =$config.FullName
                    Metadata=$metadata
                }
            }
        }
    }|Where-Object{$_.NewVersion -and ($_.Metadata.Version -ne $_.NewVersion)}
    $sortedPackages=$packages|Group-Object Config|ForEach-Object{
        $p=[PSCustomObject]@{
            Packages = ($_.Group|Sort-PackageByDependencies)
        }
        $p
    } 
    
    
    $sortedPackages|Invoke-Parallel -activityName "Update all packages" -Script {
        ($_.Packages|ForEach-Object{
            Write-host "Updating $($_.Id) in $($_.Config) to version $($_.NewVersion) from $($_.Metadata.Source)"
            (& Nuget Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source "$($_.Metadata.Source)")
        })
    }
}


