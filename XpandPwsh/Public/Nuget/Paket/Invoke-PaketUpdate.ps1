
function Invoke-PaketUpdate {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(ValueFromPipeline)]
        [switch]$Force,
        [switch]$Strict,
        [switch]$NotInteractive,
        [parameter(ParameterSetName="id")]
        [string]$ID,
        [parameter(ParameterSetName="id")]
        [string]$Version,
        [switch]$AllDependecies,
        [string]$LockMatch
    )
    
    begin {
        
    }
    
    process {
        $depArgs=@{
            Strict=$Strict
        }
        if ($Force) {
            $xtraArgs = @("--force")
        }
        Get-PaketDependenciesPath @depArgs |ForEach-Object{   
            Write-Host "Paket Update at $($_.DirectoryName)" -f Blue
            Push-Location $_.DirectoryName
            $installed=Invoke-PaketShowInstalled |Where-Object{$_.Id -eq $ID}
            if ($installed -and $Version){
                "$ID $($installed.Version) found, updating to $Version"
                $regex = [regex] "nuget (?<id>[^ ]*)(?<op> [^\d]*)(?<version>[^ \n]*)"
                $content=Get-Content $_ |ForEach-Object{
                    $match=$regex.Match($_)
                    if ($match.Success -and $match.Groups["id"].Value -eq $ID){
                        $regex.Replace($_, "nuget `${id}`${op}$Version")
                    }
                    else {
                        $_
                    }
                }
                $content|Set-Content $_
            }
            elseif (!$ID){
                if ($AllDependecies){
                    $needUpdate=Invoke-PaketShowInstalled -OnlyDirect|Where-Object{$_.id -and $_.id -notmatch $LockMatch -and $_.id -match "."} |ForEach-Object{
                        [PSCustomObject]@{
                            Id = $_.Id
                            Version=$_.Version
                            PublishedVersion=(Get-NugetPackageSearchMetadata $_.Id -Source (Get-PackageFeed -Nuget)).Identity.Version.OriginalVersion
                        }
                    }|Where-Object{
                        $_.PublishedVersion -and $_.Version -ne $_.PublishedVersion
                    }
                    $needUpdate|ForEach-Object{
                        Invoke-PaketUpdate -id $_.Id -Version $_.PublishedVersion
                    }
                    
                }
                Invoke-Script {dotnet paket update @xtraArgs}
            }
            Pop-Location
        }
    }
    
    end {
        
    }
}