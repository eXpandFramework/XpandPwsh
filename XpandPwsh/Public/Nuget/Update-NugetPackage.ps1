
function Update-NugetPackage {
    [cmdletbinding()]
    [CmdLetTag("#nuget")]
    param(
        [parameter(ValueFromPipeline, ParameterSetName = "SourcePath")]
        [string]$SourcePath = ".",
        [parameter(ParameterSetName = "projects")]
        [System.IO.FileInfo[]]$projects,
        [parameter()]
        [string]$Filter = ".*",
        [string]$ExcludeFilter ,
        [string[]]$sources = (Get-PackageSourceLocations Nuget)
    )
    if (!$projects) {
        $projects = Get-ChildItem $SourcePath *.csproj -Recurse 
        Write-HostFormatted "projects:" -Section
        $projects | Select-Object -expandProperty baseName 
    }
    
    $packages = $projects | Invoke-Parallel -ActivityName "Collecting Installed Packages" -VariablesToImport "Filter", "ExcludeFilter" -Script {
        $p = (Get-PackageReference $_.FullName).Include | Where-Object { $_ -and $_ -match $Filter }
        if ($ExcludFilter) {
            $p | Where-Object { $_ -notmatch $ExcludeFilter }
        }
        else {
            $p
        }
    } | Sort-Object -Unique

    Write-HostFormatted "installed packages:" -Section
    $packages
    $metadata = $packages | Invoke-Parallel -ActivityName "Query metadata in input sources" -VariablesToImport "sources" -Script {
        Get-NugetPackageSearchMetadata $_ ($sources -join ";")
    } | Get-SortedPackageByDependencies
    $packagesToAdd = GetPackagesToAdd $projects $Filter $ExcludeFilter $metadata
    Write-HostFormatted "packagesToAdd:$($packagesToAdd.Count)" -Section
    $packagesToAdd 
    
    while ($packagesToAdd) {
        $notPackagesToAdd = $packagesToAdd | Group-Object ProjectPath | Invoke-Parallel -ActivityName "Updating Packages" -VariablesToImport "sources" -Script {
        # $notPackagesToAdd = $packagesToAdd | Group-Object ProjectPath | foreach {
            $_.Group | ForEach-Object {
                $projectPath = $_.ProjectPath
                $p = $_.Package
                $v = $_.Version
                $output = "dotnet add $projectPath package $p -v $v `r`n"
                $output = dotnet add $projectPath package $p -v $v -n -s  $sources
                if ($output -like "*error*") {
                    [PSCustomObject]@{
                        Package = $_
                        Error   = $output
                    }
                }
            }
            
        }
        
        if ($notPackagesToAdd.Package) {
            Write-HostFormatted "Not-PackagesToAdd: $($notPackagesToAdd.Count)" -Section
            $notPackagesToAdd.Package | Out-String
            Write-Host "Error:" -ForegroundColor Red
            $notPackagesToAdd.Error | Out-String
        }
        
        $packagesToAdd = GetPackagesToAdd $projects $Filter $ExcludeFilter $metadata
        Write-HostFormatted "packagesToAdd:$($packagesToAdd.Count)" -Section
        $packagesToAdd 
    }

}
function GetPackagesToAdd($projects, $Filter, $ExcludeFilter, $metadata) {
    $projects | Invoke-Parallel -ActivityName "Identifying outdated packages" -VariablesToImport "Filter", "ExcludeFilter", "metadata" -Script {
        $csprojPath = $_.FullName
        Get-PackageReference $csprojPath | Where-Object {
            $r = $_.Include -and $_.Include -match $Filter
            if ($ExcludeFilter -and $r) {
                $_.Include -notmatch $ExcludeFilter
            }
            else {
                $r
            }
        } | ForEach-Object {
            $p = $_.Include
            $m = $metadata | Where-Object { $_.Identity.Id -eq $p }
            $latestVersion = (Get-NugetPackageMetadataVersion $m).version
            $installedVersion = $_.Version
            if ($latestVersion -ne $installedVersion) {
                [PSCustomObject]@{
                    ProjectPath = $csprojPath
                    Package     = $p
                    Version     = $latestVersion
                }
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
        [string]$Filter = ".*",
        [string]$ExcludFilter,
        [string[]]$sources = (Get-PackageSourceLocations Nuget)
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
    
        $metadatas = $configs.Content.packages.package.id | Where-Object { $_ -match $Filter -and $_ -notmatch $ExcludFilter } | Select-Object -Unique | Get-NugetPackageSearchMetadata -Source $sources
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
                $metadata = $metadatas | Where-Object { $_.Identity.Id -eq $packageId }
                if ($metadata) {
                    $csproj = Get-ChildItem $config.DirectoryName *.csproj | Select-Object -first 1
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
                $deps = $obj.DependencySets.Packages | Select-Object -ExpandProperty Id
                $exist = $all | Select-Object -ExpandProperty Identity | Where-Object { $deps -contains $_.Id }
                if (!$exist) {
                    $list.Add($obj) | Out-Null
                }
            }
            $list | ForEach-Object {
                $all.Remove($_) | Out-Null
            }
        }
        $list | ForEach-Object { $_ }
    }
}



