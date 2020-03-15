function Pop-XafPackage {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory)]
        [string]$PackageSource,
        [parameter(Mandatory)]
        [version]$Version,
        [string]$OutputFolder=(Get-NugetInstallationFolder GlobalPackagesFolder) 
    )
    
    begin {
        if (!(Test-Path $OutputFolder))        {
            New-Item $OutputFolder -ItemType Directory
        }
        $PSCmdlet|Write-PSCmdletBegin
    }
    
    process {
        Invoke-Script{
            $existingPackages=Get-ChildItem $OutputFolder DevExpress*$dxVersion*.nupkg  -Recurse|ConvertTo-PackageObject 
            $m=Get-NugetPackageSearchMetadata -Source $PackageSource | Where-Object{
                $id=$_.Identity.Id
                !("de","es","ja","ru"|Where-Object{ $id -like "*.$_"}) -and $id -notmatch "\.wpf\.|\.xamarinforms\.|\.web\.mvc|\.WindowsDesktop\." 
            }
            $existingMetadata=(($m|ForEach-Object{
                [PSCustomObject]@{
                    Id = $_.Identity.Id
                    Version=$_.Identity.Version.OriginalVersion
                }
            }))+(($m.dependencySets.packages|Sort-Object Id -Unique|Where-Object{$_.id -notin $m.Identity.id -and $_.id -match "DevExpress"})|ForEach-Object{
                [PSCustomObject]@{
                    Id = $_.Id
                    Version=$_.versionrange.maxversion.originalversion
                }
            })
            "existingMetadata"|Get-Variable|Out-Variable
    
            $missingMetadata=$existingMetadata|ForEach-Object{
                $pVersion=(Get-VersionPart $_.Version Build)
                if ($pVersion -in $Version){
                    $p=$_
                    if ((!$existingPackages -or !($existingPackages|Where-Object{$_.id -eq $p.id -and  $_.version -eq $pVersion}))){
                        $_
                    }
                }
            }
            "missingMetadata"|Get-Variable|Out-Variable
            if ($missingMetadata){
                $downloadedPackages=$missingMetadata|Invoke-Parallel -ActivityName "Downloading XAF packages" -VariablesToImport @("PackageSource","OutputFolder") -LimitConcurrency ([System.Environment]::ProcessorCount) -Script{
                    Get-NugetPackage $_.Id -Source $PackageSource -ResultType DownloadResults -OutputFolder $OutputFolder
                } 
                
                $newPackages=$downloadedPackages.PackageStream.name|Get-Item|ConvertTo-PackageObject
                "newPackages"|Get-Variable|Out-Variable
                ($newPackages+$allMetadata)|Sort-Object id -Unique
            }
            else {
                $existingMetadata
            }        
        }
    }
    
    end {
        
    }
}
