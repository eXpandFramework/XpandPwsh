function Get-XpandPackages {
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet("Release","Lab")]
        $Source,
        [ValidateSet("All","eXpand","XAF","XAFAll")]
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
        elseif ($PackageType -eq "XAF"){
            $Filter="Xpand.XAF.Modules*"
        }
        elseif ($PackageType -eq "XAFAll"){
            $Filter="Xpand.XAF.Modules*;Xpand.Extensions*"
        }
        $nuget=Get-Nugetpath
        if (($Source -eq "Release") -or !$Source){
            $query=& $nuget List author:eXpandFramework -source (Get-PackageFeed -Nuget)
            
        }
        else{
            $query=& $nuget List -source (Get-PackageFeed -Xpand)
        }
        $filter.split(";")|ForEach-Object{
            $f=$_
            $query|Where-Object{$_ -like $f}|ConvertTo-PackageObject
        }
        
    }
    
    end {
    }
}
