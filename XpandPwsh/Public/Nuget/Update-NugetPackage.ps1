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
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin   
    }
    
    process {
        if (!$projects) {
            $projects = Get-ChildItem $SourcePath *.csproj -Recurse 
            
            $projectsName=$projects | Select-Object -expandProperty baseName 
            "projectsName"|Out-VariableValue
        }
        
        $installedPackages = $projects | Invoke-Parallel -ActivityName "Collecting Installed Packages" -VariablesToImport "Filter", "ExcludeFilter" -Script {
            $p = (Get-PackageReference $_.FullName).Include | Where-Object { $_ -and $_ -match $Filter }
            if ($ExcludFilter) {
                $p | Where-Object { $_ -notmatch $ExcludeFilter }
            }
            else {
                $p
            }
        } | Sort-Object -Unique
    
        "installedPackages"|Out-VariableValue
        $metadata = $installedPackages | Invoke-Parallel -ActivityName "Query metadata in input sources" -VariablesToImport "sources" -Script {
            $mdata=Get-NugetPackageSearchMetadata $_ ($sources -join ";")
            if (!$mdata){
                throw "Metatdata for $_ not found in $($sources -join ";")"
            }
            $mdata
        } 
        $packagesToAdd = GetPackagesToAdd $projects $Filter $ExcludeFilter $metadata
        "packagesToAdd"|Out-VariableValue 

        $packagesToAdd|Group-Object ProjectPath |ForEach-Object{
            write-hostformatted "Update packages in $($_.Name)" -section -streamtype verbose -foregroudcolor Blue
            [xml]$proj=Get-XmlContent $_.Name
            $_.Group|ForEach-Object{
                Add-PackageReference -Package $_.Package -Version $_.Version -Project $proj 
            }
            $proj|Save-Xml $_.Name|Out-Null
            
        }        
    }
    
    end {
        
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
            $latestVersion = $m.Identity.Version.OriginalVersion
            $installedVersion = $_.Version
            if ($latestVersion -gt $installedVersion) {
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



