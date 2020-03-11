function Pop-XpandPackage {
    [CmdLetTag()]
    [CmdletBinding()]
    param (
        [ValidateSet("Core","Win","Web")]
        [string[]]$Platform=@("Win","Web","Core"),
        [parameter(Mandatory)]
        [ValidateSet("Lab","Release")]
        [string]$PackageSource,
        [string]$OutputFolder=(Get-NugetInstallationFolder GlobalPackagesFolder) 
    )
    
    begin {
        if (!(Test-Path $OutputFolder))        {
            New-Item $OutputFolder -ItemType Directory
        }        
    }
    
    process {
        $allMetadata=Get-XpandPackages -Source  $PackageSource All|ForEach-Object{
            [PSCustomObject]@{
                Id = $_.Id
                Version=(Get-VersionPart $_.Version Build)
            }
        } 
        $existingPackages=Get-ChildItem $OutputFolder *Xpand*.nupkg  -Recurse|ConvertTo-PackageObject|Where-Object{
            $p=$_
            $allMetadata|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version}
        }
        
        $missingMetadata=$allMetadata|Where-Object{
            $p=$_
            !($existingPackages|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version})
        }
        if ($missingMetadata){
            $source=Get-PackageFeed -FeedName $PackageSource
            $newMetadata=$missingMetadata|Invoke-Parallel -ActivityName "Dowloading Xpand packages " -VariablesToImport @("source","OutputFolder") -LimitConcurrency ([System.Environment]::ProcessorCount) -Script{
                Get-NugetPackage $_.Id -Source $source -ResultType DownloadResults -OutputFolder $OutputFolder -Versions $_.Version
            }   
            (@($newMetadata.PackageStream.name|Get-Item|ConvertTo-PackageObject)+$allMetadata)|Sort-Object id -Unique
        }
        else{
            $existingPackages
        }        
    }
    
    end {
        
    }
}