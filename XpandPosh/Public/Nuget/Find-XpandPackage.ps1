function Find-XpandPackage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$Name,
        [parameter()]
        [ValidateSet("All","Release","Lab")]
        [string]$PackageSource="All"
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
            $sourceFilter=Get-PackageFeed -Xpand
            if ($packageSource -eq "Release") {
                $sourceFilter=Get-PackageFeed -Nuget
            }
            $source =$sources| Where-Object { $_.Location -like $sourceFilter }|Select-Object -ExpandProperty Name -First 1
            $sArgs.Add("Source", $source)
        }
        Write-Verbose "sArgs:"
        Write-Verbose ($sArgs | out-string)
        $packages = Find-Package @sArgs 
        $packages|ForEach-Object{
            $isXpandPackage=($_|ConvertTo-Object).Entities| Where-Object {
                $_.Role -eq "Author" -and $_.Name -eq "eXpandFramework"
            }
            if ($isXpandPackage){
                $_
            }

        }
        
    }
    
    end {
    }
}