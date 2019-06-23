
function Update-NugetPackage {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline,ParameterSetName="SourcePath")]
        [string]$SourcePath = ".",
        [parameter(ParameterSetName="projects")]
        [System.IO.FileInfo[]]$projects,
        [string]$RepositoryPath,
        [parameter()]
        [string]$Filter = "*",
        [string]$sources = ((Get-PackageSourceLocations Nuget) -join ";")
    )
    write-host "PackagesConfig" -f Blue 
    Update-NugetPackagesConfig $SourcePath $RepositoryPath $Filter $sources
    write-host "PackageReference" -f blu
    if (!$projects){
        $projects=Get-ChildItem $SourcePath *.csproj -Recurse 
    }
    write-host "projects:" -f blue
    
    $packages=$projects|ForEach-Object{
        [xml]$csproj=Get-Content $_.FullName
        $csproj.Project.ItemGroup.PackageReference.Include|Where-Object{$_ -and $_ -like $Filter}
    }|Sort-object -Unique
    write-host "packages:" -f blue
    $packages
    $metadata=$packages|ForEach-Object{
        Get-NugetPackageSearchMetadata $_ $sources
    }
    
    $packagesToAdd=$projects|ForEach-Object{
        $csprojPath=$_.FullName
        $csprojName=$_.BaseName
        [xml]$csproj=Get-Content $csprojPath
        $csproj.Project.ItemGroup.PackageReference|Where-Object{$_.Include -and $_.Include -like $Filter}|ForEach-Object{
            $p=$_.Include
            $m=$metadata|Where-Object{$_.Identity.Id -eq $p}
            $latestVersion = (Get-NugetPackageMetadataVersion $m).version
            $installedVersion=$_.Version
            if ($latestVersion -ne $installedVersion){
                Write-host "Updating $csprojName $p $installedVersion to $latestVersion" -f Green
                [PSCustomObject]@{
                    ProjectPath = $csprojPath
                    Package=$p
                    Version=$latestVersion
                    Sources=$sources
                }
            }
        }
    }
    $packagesToAdd|Write-Verbose
    if ($packagesToAdd){
        # $packagesToAdd|Invoke-Parallel -StepInterval 100 -Script{
        $packagesToAdd|foreach{
            dotnet add $_.ProjectPath package $_.Package -v $_.Version -s $_.Sources -n|Write-Verbose
            IF ($LASTEXITCODE){
                throw
            }
        }
    }
    
}

function Update-NugetPackagesConfig {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$SourcePath = ".",
        [string]$RepositoryPath,
        [parameter()]
        [string]$Filter = "*",
        [string]$sources = ((Get-PackageSourceLocations Nuget) -join ";")
    )
    
    begin {
    }
    
    process {
        $configs = Get-ChildItem $sourcePath packages.config -Recurse | ForEach-Object {
            [PSCustomObject]@{
                Content = [xml]$(Get-Content $_.FullName)
                Config  = $_
            }
        }
    
        $metadatas = $configs.Content.packages.package.id | Where-Object { $_ -like $Filter } | Select-Object -Unique | Get-NugetPackageSearchMetadata -Source $sources
        $metadatas | ForEach-Object {
            [PSCustomObject]@{
                Title   = $_.Title
                Version = $_.Identity.Version.Version
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
                    $latestVersion = (Get-NugetPackageMetadataVersion $metadata).version
                    [PSCustomObject]@{
                        Id         = $packageId
                        NewVersion = $latestVersion
                        Config     = $config.FullName
                        csproj     = $csproj.FullName
                        Version    = $_.Version
                    }
                }
            }
        } | Where-Object { $_.NewVersion -and ($_.Version -ne $_.NewVersion) }
        $sortedPackages = $packages | Group-Object Config | ForEach-Object {
            $p = [PSCustomObject]@{
                Packages = ($_.Group | Get-SortedPackageByDependencies)
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
    
    end {
    }
}

function Get-SortedPackageByDependencies {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $psObj
    )
    begin {
        $all = New-Object System.Collections.ArrayList
    }
    
    process {
        $all.Add($psObj) | Out-Null
    }
    
    end {
        $list = New-Object System.Collections.ArrayList
        
        while ($all.Count) {
            $all | ForEach-Object {
                $obj = $_
                $deps = $obj.Metadata.Metadata.DependencySets.Packages | select -ExpandProperty Id
                $exist = $all | Select-Object -ExpandProperty Id | Where-Object { $deps -contains $_ }
                if (!$exist) {
                    $list.Add($obj) | out-null
                }
            }
            $list | ForEach-Object {
                $all.Remove($_) | out-null
            }
        }
        $list | ForEach-Object { $_ }
    }
}



