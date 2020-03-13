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
        $PSCmdlet|Write-PSCmdletBegin    
    }
    
    process {
        $allMetadata=Get-XpandPackages -Source  $PackageSource All|ForEach-Object{
            $version=$_.Version
            if ($version.Revision -lt 1){
                $version=Get-VersionPart $_.Version Build
            }
            [PSCustomObject]@{
                Id = $_.Id
                Version=$version
            }
        } 
        "allMetadata"|Out-VariableValue
        $existingPackages=Get-ChildItem $OutputFolder *Xpand*.nupkg  -Recurse|ConvertTo-PackageObject|Where-Object{
            $p=$_
            $allMetadata|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version}
        }
        "existingPackages"|Out-VariableValue
        $missingMetadata=$allMetadata|Where-Object{
            $p=$_
            !($existingPackages|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version})
        }

        "missingMetadata"|Out-VariableValue
        if ($missingMetadata){
            $source=Get-PackageFeed -FeedName $PackageSource
            # $newMetadata=$missingMetadata|Invoke-Parallel -ActivityName "Dowloading Xpand packages " -VariablesToImport @("source","OutputFolder") -LimitConcurrency ([System.Environment]::ProcessorCount) -Script{
            $newMetadata=$missingMetadata|foreach{
                Get-NugetPackage $_.Id -Source $source -ResultType DownloadResults -OutputFolder $OutputFolder -Versions $_.Version
            }   
            $downloadedPackages=$newMetadata.PackageStream.name|Get-Item|ConvertTo-PackageObject
            "downloadedPackages"|Out-VariableValue
            ($downloadedPackages+$allMetadata)|Sort-Object id -Unique
        }
        else{
            $existingPackages
        }        
    }
    
    end {
        
    }
}