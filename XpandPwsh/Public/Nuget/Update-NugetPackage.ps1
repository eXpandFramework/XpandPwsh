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
        Invoke-Script{
            if (!$projects) {
                $projects = Get-ChildItem $SourcePath *.csproj -Recurse 
                
                $projectsName=$projects | Select-Object -expandProperty baseName 
                "projectsName"|Get-Variable|Out-Variable
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
        
            "installedPackages"|Get-Variable|Out-Variable
            $metadata = $installedPackages | Invoke-Parallel -ActivityName "Query metadata in input sources" -VariablesToImport "sources" -Script {
                $mdata=Get-NugetPackageSearchMetadata $_ ($sources -join ";")
                if (!$mdata){
                    throw "Metatdata for $_ not found in $($sources -join ";")"
                }
                $mdata
            } 
            $packagesToAdd = GetPackagesToAdd $projects $Filter $ExcludeFilter $metadata
            "packagesToAdd"|Get-Variable|Out-Variable 
    
            $packagesToAdd|Group-Object ProjectPath |ForEach-Object{
                write-hostformatted "Update packages in $($_.Name)" -section -streamtype verbose -foregroudcolor Blue
                [xml]$proj=Get-XmlContent $_.Name
                $_.Group|ForEach-Object{
                    Add-PackageReference -Package $_.Package -Version $_.Version -Project $proj 
                }
                $proj|Save-Xml $_.Name|Out-Null
                
            }        
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




