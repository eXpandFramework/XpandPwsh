function Get-XpandPackages{
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet("Release","Lab")]
        $Source
    )
    
    begin {
    }
    
    process {
        $nuget=Get-Nugetpath
        if (($Source -eq "Release") -or !$Source){
            & $nuget List author:eXpandFramework -source (Get-PackageFeed -Nuget)|Where-Object{$_ -like "eXpand*"}|ConvertTo-PackageObject|Select-Object -ExpandProperty Name
        }
        else{
            & $nuget List eXpand -source (Get-PackageFeed -Xpand)|Where-Object{$_ -like "eXpand*"}|ConvertTo-PackageObject|Select-Object -ExpandProperty Name
        }
    }
    
    end {
    }
}
