function Find-XpandPackage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Filter,
        [parameter(Position = 1)]
        [ValidateSet("All", "Release", "Lab")]
        [string]$PackageSource = "Release"
    )
    
    begin {
    }
    
    process {
        
        if ($PackageSource -ne "all") {
            $packages=Get-XpandPackages -Source $PackageSource 
            $p=$packages| Where-Object { 
                $_.Id -like $Filter 
            }
        }
        else{
            $p = $(Find-XpandPackage -Filter $Filter -PackageSource Lab) , $(Find-XpandPackage -Filter $Filter -PackageSource Release)
        }
        $p 
    }
    
    end {
    }
}