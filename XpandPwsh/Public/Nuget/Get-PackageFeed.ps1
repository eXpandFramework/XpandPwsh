function Get-PackageFeed {
    param(
        [switch]$Xpand,
        [switch]$Nuget,
        [switch]$GitHubLab,
        [ValidateSet("Xpand","Nuget","Lab","Release")]
        [string]$FeedName
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
    if ($FeedName){
        if ($FeedName -eq "lab"){
            $fname="Xpand"
        }
        if ($FeedName -eq "Release"){
            $fname="Nuget"
        }
        $a = @{
            $fname = $true
        }
        Get-PackageFeed @a
    }
}