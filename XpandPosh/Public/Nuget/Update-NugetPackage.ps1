
function Update-NugetPackage{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$SourcePath=".",
        [parameter(Mandatory)]
        [string]$RepositoryPath,
        [parameter()]
        [string]$Filter="*"
    )
    $configs=Get-ChildItem $sourcePath packages.config -Recurse|ForEach-Object{
        [PSCustomObject]@{
            Content = [xml]$(Get-Content $_.FullName)
            Config = $_
        }
    }
    write-host "configs" -f Blue
    $configs.Content.Packages.package.id
    $sources=((Get-PackageSourceLocations Nuget) -join ";")
    $metadatas=$configs.Content.packages.package.id|Where-Object{$_ -like $Filter}|Select-Object -Unique |
    Get-NugetPackageSearchMetadata -Source $sources|Get-NugetPackageMetadataVersion|
    Group-Object Name|ForEach-Object{
        $_.Group|Sort-Object Version -Descending|Select-Object -First 1
    }
    $metadatas|Write-Output
    
    $packages=$configs|ForEach-Object{
        $config=$_.Config
        $_.Content.packages.package|Where-Object{$_.id -like $filter}|ForEach-Object{
            $packageId=$_.Id
            $metadata=$metadatas|Where-object{$_.Name -eq $packageId}
            if ($metadata){
                $csproj=Get-ChildItem $config.DirectoryName *.csproj|Select -first 1
                [PSCustomObject]@{
                    Id = $packageId
                    NewVersion = $metadata.Version
                    Config =$config.FullName
                    csproj =$csproj.FullName
                    Version=$_.Version
                }
            }
        }
    }|Where-Object{$_.NewVersion -and ($_.Version -ne $_.NewVersion)}
    $sortedPackages=$packages|Group-Object Config|ForEach-Object{
        $p=[PSCustomObject]@{
            Packages = ($_.Group|Sort-PackageByDependencies)
        }
        $p
    } 
    
    
    $sortedPackages|Invoke-Parallel -activityName "Update all packages" -VariablesToImport @("RepositoryPath","sources") -Script {
    # $sortedPackages|ForEach-Object {
        ($_.Packages|ForEach-Object{

            Write-host "Updating $($_.Id) in $($_.Config) to version $($_.NewVersion) from $($_.Metadata.Source)"
            & (Get-NugetPath) Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source $sources -NonInteractive -RepositoryPath $RepositoryPath
        })
    }
}


