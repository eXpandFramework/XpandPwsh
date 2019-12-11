function Get-XafPackageNames{
    param(
        [parameter(Mandatory)]
        [string]$Version
    )
    (((Get-DxNugets -version $version).Package|Where-Object{$_ -like "DevExpress.ExpressApp*"})+@("All","All.Win","All.Web"))|Where-Object{
        $p=$_
        !(".ja",".ru",".de",".es"|Where-Object{$p -like "*$_"})
    }|ForEach-Object{
        $_
    }|Sort-Object -Unique 
}