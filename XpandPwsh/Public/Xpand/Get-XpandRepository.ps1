function Get-XpandRepository {
    [CmdletBinding()]
    [CmdLetTag()]
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
        $url = "https://$GithubUserName`:$GithubUserPass@github.com/eXpandFramework/$Name.git"
        git clone $url -q
        Set-Location "$Location\$Name"
    }
    
    end {
    }
}