function Get-PackageFeed {
    param(
        [switch]$Xpand,
        [switch]$Nuget
    )
    if ($Xpand){
        "https://xpandnugetserver.azurewebsites.net/nuget"
    }
    if ($Nuget){
        "https://api.nuget.org/v3/index.json"
    }
}