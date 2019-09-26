function Get-XpandPackages {
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet("Release","Lab")]
        $Source,
        [ValidateSet("All","eXpand","XAF")]
        $PackageType="eXpand"
    )
    
    begin {
    }
    
    process {
        if ($PackageType -eq "All"){
            $Filter="*"
        }
        elseif ($PackageType -eq "eXpand") {
            $Filter="eXpand*"
        }
        else{
            $Filter="Xpand.XAF.Modules*"
        }
        $nuget=Get-Nugetpath
        if (($Source -eq "Release") -or !$Source){
            & $nuget List author:eXpandFramework -source (Get-PackageFeed -Nuget)|Where-Object{$_ -like $Filter}|ConvertTo-PackageObject
        }
        else{
            & $nuget List -source (Get-PackageFeed -Xpand)|Where-Object{$_ -like $Filter}|ConvertTo-PackageObject
        }
    }
    
    end {
    }
}
