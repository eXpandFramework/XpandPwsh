function Get-XafPackages{
    param(
        [parameter(Mandatory)]
        [string]$Version
    )
    (((Get-DxNugets -version $version).Package|Where-Object{$_ -like "DevExpress.ExpressApp*"})+@("All","All.Win","All.Web"))|ForEach-Object{
        $_.Replace("DevExpress.ExpressApp.","").Replace("DevExpress","")
    }|Where-Object{
        $p=$_
        !(".ja",".ru",".de",".es"|Where-Object{$p -like "*$_"})
    }|Sort-Object -Unique
}