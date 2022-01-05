
function Get-PackageFeed {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [switch]$Xpand,
        [switch]$Nuget,
        [switch]$GitHubLab,
        [switch]$AzDevOps,
        [ValidateSet("Xpand","Nuget","Lab","Release","AzDevOps")]
        [string]$FeedName
    )
    
    begin {
        
    }
    
    process {
        if ($Xpand){
            "https://xpandnugetserver.azurewebsites.net/nuget"
        }
        if ($Nuget){
            "https://api.nuget.org/v3/index.json"
        }
        if ($GitHubLab){
            "https://nuget.pkg.github.com/eXpandFramework/index.json"
        }
        if ($AzDevOps){
            "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json"
        }
        if ($FeedName){
            if ($FeedName -eq "lab"){
                $fname="Xpand"
            }
            if ($FeedName -eq "Release"){
                $fname="Nuget"
            }
            if ($FeedName -eq "AzDevOps"){
                $fname="AzDevOps"
            }
            $a = @{
                $fname = $true
            }
            Get-PackageFeed @a
        }        
    }
    
    end {
        
    }
}
