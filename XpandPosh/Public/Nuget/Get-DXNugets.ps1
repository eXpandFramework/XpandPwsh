function Get-DxNugets{
    param(
        [parameter(Mandatory)]
        [string]$version
    )
    Write-Verbose "Downloading from https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv"
    (new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv")|ConvertFrom-csv
}