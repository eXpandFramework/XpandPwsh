function Find-XpandPackage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline,Position=0)]
        [string]$Name,
        [parameter(Position=1)]
        [ValidateSet("All", "Release", "Lab")]
        [string]$PackageSource = "All",
        [switch]$AllVersions,
        [int]$First=3
    )
    
    begin {
    }
    
    process {
        $sArgs = @{
            Name         = "*$Name*"
            ProviderName = "Nuget"
        }
        if ($PackageSource -ne "All") {
            $sources = Get-PackageSource
            $sourceFilter = Get-PackageFeed -Xpand
            if ($packageSource -eq "Release") {
                $sourceFilter = Get-PackageFeed -Nuget
            }
            $source = $sources | Where-Object { $_.Location -like $sourceFilter } | Select-Object -ExpandProperty Name -First 1
            $sArgs.Add("Source", $source)
        }
        Write-Verbose "sArgs:"
        Write-Verbose ($sArgs | out-string)
        $packages = Find-Package @sArgs 
        IF ($AllVersions){
            $sArgs.Add("AllVersions", $AllVersions)
        }
        $packages | ForEach-Object {
            $isXpandPackage = ($_ | ConvertTo-Object).Entities | Where-Object {
                $_.Role -eq "Author" -and $_.Name -eq "eXpandFramework"
            }
            if ($isXpandPackage) {
                if (!$AllVersions) {
                    $_
                }
                else {           
                    $sArgs.Name = $_.Name
                    $allPackages=Find-Package @sArgs 
                    if ($First -gt 0){
                        $allPackages|Group-Object Source|ForEach-Object{
                            $_.group|Select-Object -First $First
                        }
                    }
                    else{
                        $allPackages
                    }
                }
            }
        }
    }
    
    end {
    }
}