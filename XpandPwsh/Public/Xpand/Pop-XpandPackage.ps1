function Pop-XpandPackage {
    [CmdLetTag()]
    [CmdletBinding()]
    param (
        [ValidateSet("Core","Win","Web")]
        [string[]]$Platform=@("Win","Web","Core"),
        [parameter(Mandatory)]
        [ValidateSet("Lab","Release")]
        [string]$PackageSource,
        [string]$OutputFolder=(Get-NugetInstallationFolder GlobalPackagesFolder) ,
        [version]$Version,
        [ValidateSet("All","XAFAll","Xpand")]
        [string]$PackageType

    )
    
    begin {
        if (!(Test-Path $OutputFolder))        {
            New-Item $OutputFolder -ItemType Directory
        }        
        $PSCmdlet|Write-PSCmdletBegin    
        if ($Version ){
            if ($PackageType -eq "All"){
                throw "PackageType value cannot be All when Version is set"
            }
            $containers="Xpand.XAF.Win.All","Xpand.XAF.Web.All"
            if ($PackageType -eq "Xpand"){
                $containers="eXpandAgnostic","eXpandWeb","eXpandWin"
            }
            $publishedMetadata=$containers|Get-XpandNugetPackageDependencies -Version $Version -Source (Get-PackageFeed -FeedName $PackageSource)|ForEach-Object{
                [PSCustomObject]@{
                    Id = $_.Id
                    Version=$_.VersionRange.OriginalString
                }
            }
            $publishedMetadata+=$containers|ForEach-Object{
                [PSCustomObject]@{
                    Id = $_
                    Version=$Version
                }
            }
            "publishedMetadata"|Get-Variable|Out-Variable
        }
    }
    
    process {
        if (!$publishedMetadata){
            $publishedMetadata=@(Get-XpandPackages -Source  $PackageSource All)    
        }        
        if ($PackageSource -eq "Lab"){
            $releasePackages=(Get-XpandPackages -Source  Release All|Where-Object{$_.Id -notin $publishedMetadata.id})
            if ($PackageType -eq "XAFAll"){
                $releasePackages=$releasePackages|Where-Object{$_.Id -notLike "eXpand*"}
            }
            $publishedMetadata+=$releasePackages|Where-Object{
                if ($PackageType -eq "Xpand"){
                    $_.Id -notlike "Xpand*"
                }
                else{
                    $true
                }
            }
        }
        $allMetadata=$publishedMetadata|ForEach-Object{
            $version=$_.Version
            if ($version.Revision -lt 1){
                $version=Get-VersionPart $_.Version Build
            }
            [PSCustomObject]@{
                Id = $_.Id
                Version=$version
            }
        } 
        "allMetadata"|Get-Variable|Out-Variable
        $existingPackages=Get-ChildItem $OutputFolder *Xpand*.nupkg  -Recurse|ConvertTo-PackageObject|Where-Object{
            $p=$_
            $allMetadata|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version}
        }
        "existingPackages"|Get-Variable|Out-Variable
        $missingMetadata=$allMetadata|Where-Object{
            $p=$_
            !($existingPackages|Where-Object{$_.Id -eq $p.Id -and $_.Version -eq $p.version})
        }

        "missingMetadata"|Get-Variable|Out-Variable
        if ($missingMetadata){
            $source="$(Get-PackageFeed -Xpand)","$(Get-PackageFeed -Nuget)"
            $newMetadata=$missingMetadata|Invoke-Parallel -ActivityName "Dowloading Xpand packages " -VariablesToImport @("source","OutputFolder") -LimitConcurrency ([System.Environment]::ProcessorCount) -Script{
                Get-NugetPackage $_.Id -Source $source -ResultType DownloadResults -OutputFolder $OutputFolder -Versions $_.Version
            }   
            $downloadedPackages=$newMetadata.PackageStream.name|Get-Item|ConvertTo-PackageObject
            "downloadedPackages"|Get-Variable|Out-Variable
            ($downloadedPackages+$existingPackages)|Sort-Object id -Unique
        }
        else{
            $existingPackages
        }        
    }
    
    end {
        
    }
}