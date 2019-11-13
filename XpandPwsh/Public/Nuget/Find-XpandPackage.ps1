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
        
        Write-Verbose ($fArgs | Out-String)
        $nuget = (Get-NugetPath)
        if ($PackageSource -eq "Lab") {
            $p = & ($nuget) list -Source (Get-PackageFeed -Xpand)| ConvertTo-PackageObject | Where-Object { $_.Id -like $Filter }
        }
        elseif ($PackageSource -eq "All") {
            $p = $(Find-XpandPackage -Filter $Filter -PackageSource Lab) , $(Find-XpandPackage -Filter $Filter -PackageSource Release)
        }
        elseif ($PackageSource -eq "Release") {
            $p=& (Get-NugetPath) list author:expandframework -source (Get-PackageFeed -Nuget)
            $p = $p|ConvertTo-PackageObject | Where-Object { $_.Id -like $Filter }
        }
        $p 
    }
    
    end {
    }
}