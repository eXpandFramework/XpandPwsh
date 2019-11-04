function Get-PackageFeed {
    param(
        [switch]$Xpand,
        [switch]$Nuget,
        [switch]$GitHubLab
    )
    if ($Xpand){
        "https://xpandnugetserver.azurewebsites.net/nuget"
    }
    if ($Nuget){
        "https://api.nuget.org/v3/index.json"
    }
    if ($GitHubLab){
        "https://nuget.pkg.github.com/eXpandFramework/index.json"
    }
}