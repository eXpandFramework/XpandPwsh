function Get-PackageFeed {
    param(
        [switch]$Xpand,
        [switch]$Nuget
    )
    if ($Xpand){
        "http://lab.nugetserver.expandframework.com/nuget"
    }
    if ($Nuget){
        "https://api.nuget.org/v3/index.json"
    }
}