function Get-XpandRepository {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        [ValidateSet("eXpand","eXpand.lab","DevExpress.XAF","XpandPwsh")]
        [string]$Name,
        [parameter()]
        [string]$GitHubUserName,
        [parameter()]
        [string]$GitHubUserPass,
        [string]$Location = "$env:TEMP\$Name",
        [switch]$Uri
    )
    
    begin {
    }
    
    process {
        $url = "https://"
        if ($GitHubUserName -and $GitHubUserPass){
            $url+="$GithubUserName`:$GithubUserPass@"
        }
        $url+="github.com/eXpandFramework/$Name.git"
        if (!$Uri){
            if (Test-Path $Location) {
                Remove-Item $Location -Recurse -Force
            }
            New-Item $Location -ItemType Directory -Force 
            Set-Location $Location
            git clone $url -q
            Set-Location "$Location\$Name"
        }
        else{
            $url
        }
    }
    
    end {
    }
}