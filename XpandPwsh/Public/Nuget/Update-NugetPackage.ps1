
function Update-NugetPackage {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$SourcePath = ".",
        [string]$RepositoryPath,
        [parameter()]
        [string]$Filter = "*",
        [string]$sources = ((Get-PackageSourceLocations Nuget) -join ";")
    )
    $configs = Get-ChildItem $sourcePath packages.config -Recurse | ForEach-Object {
            [PSCustomObject]@{
                Content = [xml]$(Get-Content $_.FullName)
                Config  = $_
            }
    }
    
    $metadatas = $configs.Content.packages.package.id | Where-Object { $_ -like $Filter } | Select-Object -Unique | Get-NugetPackageSearchMetadata -Source $sources
    $metadatas|ForEach-Object{
        [PSCustomObject]@{
            Title=$_.Title
            Version=$_.Identity.Version.Version
        }
    }
    $packages = $configs | ForEach-Object {
        $_.Config.FullName
        $config = $_.Config
        $_.Content.packages.package | Where-Object { $_.id -like $filter } | ForEach-Object {
            $packageId = $_.Id
            $metadata = $metadatas | Where-object { $_.Identity.Id -eq $packageId }
            if ($metadata) {
                $csproj = Get-ChildItem $config.DirectoryName *.csproj | Select -first 1
                $newVersion=(Get-NugetPackageMetadataVersion $metadata).version
                [PSCustomObject]@{
                    Id         = $packageId
                    NewVersion = $newVersion
                    Config     = $config.FullName
                    csproj     = $csproj.FullName
                    Version    = $_.Version
                }
            }
        }
    } | Where-Object { $_.NewVersion -and ($_.Version -ne $_.NewVersion) }
    $sortedPackages = $packages | Group-Object Config | ForEach-Object {
        $p = [PSCustomObject]@{
            Packages = ($_.Group | Sort-PackageByDependencies)
        }
        $p
    } 
    
    
    $sortedPackages | Invoke-Parallel -activityName "Update all packages" -VariablesToImport @("RepositoryPath", "sources") -Script {
        ($_.Packages | ForEach-Object {
                if ($RepositoryPath) {
                    & (Get-NugetPath) Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source $sources -NonInteractive -RepositoryPath $RepositoryPath
                }
                else {
                    & (Get-NugetPath) Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source $sources -NonInteractive 
                }
            
            })
    }
}


function Sort-PackageByDependencies {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $psObj
    )
    begin {
        $all=New-Object System.Collections.ArrayList
    }
    
    process {
        $all.Add($psObj)|Out-Null
    }
    
    end {
        $list=New-Object System.Collections.ArrayList
        
        while ($all.Count) {
            $all|ForEach-Object{
                $obj=$_
                $deps=$obj.Metadata.Metadata.DependencySets.Packages|select -ExpandProperty Id
                $exist=$all|Select-Object -ExpandProperty Id|Where-Object{$deps -contains $_}
                if (!$exist){
                    $list.Add($obj)|out-null
                }
            }
            $list|ForEach-Object{
                $all.Remove($_)|out-null
            }
        }
        $list|ForEach-Object{$_}
    }
}



