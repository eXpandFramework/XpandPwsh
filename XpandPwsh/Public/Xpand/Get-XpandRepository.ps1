function Get-XpandRepository {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [ValidateSet("eXpand","eXpand.lab","DevExpress.XAF","XpandPwsh")]
        [string]$Name,
        [parameter(Mandatory)]
        $GitHubUserName,
        [parameter(Mandatory)]
        $GitHubUserPass,
        $Location = "$env:TEMP\$Name"
    )
    
    begin {
    }
    
    process {
        
        if (Test-Path $Location) {
            Remove-Item $Location -Recurse -Force
        }
        New-Item $Location -ItemType Directory -Force 
        Set-Location $Location
        $url = "https://$GithubUserName`:$GithubPass@github.com/eXpandFramework/$Name.git"
        git clone $url
        Set-Location "$Location\$Name"
    }
    
    end {
    }
}