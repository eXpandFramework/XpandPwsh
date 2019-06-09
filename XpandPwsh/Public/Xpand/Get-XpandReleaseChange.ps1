
function Get-XpandReleaseArtifact {
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet("Label", "Release")]
        [string]$Artifact = "Label"
    )
    
    begin {
    }
    
    process {
        $client = [System.Net.WebClient]::new()
        $History = $client.DownloadString("https://raw.githubusercontent.com/eXpandFramework/eXpand.lab/history/ReleaseNotesHistory/History.csv") | ConvertFrom-Csv 
        if ($Artifact -eq "Label") {
            ($History | ForEach-Object { $_.Labels | ForEach-Object { $_.split(", ") } } | Sort-Object -Unique) | Where-Object { $_ } | ForEach-Object { "$_" }
        }
        elseif ($Artifact -eq "Release") {
            $History | ForEach-Object { [version]$_.Release } | Sort-Object -Unique -Descending
        }
    }
    
    end {
    }
}

function Get-XpandReleaseChange {
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateScript( {
                $_ -in (Get-XpandReleaseArtifact Label)
            })]
        [ArgumentCompleter( {
                . "$PSCommandPath"
                (Get-XpandReleaseArtifact Label)
            })]
        $Label,
        [ValidateScript( {
                $_ -in (Get-XpandReleaseArtifact Release)
            })]
        [ArgumentCompleter( {
                . "$PSCommandPath"
                (Get-XpandReleaseArtifact Release)
            })]
        [parameter()]
        [string]$SinceVersion,
        [ValidateScript( {
                $_ -in (Get-XpandReleaseArtifact Release)
            })]
        [ArgumentCompleter( {
                . "$PSCommandPath"
                (Get-XpandReleaseArtifact Release)
            })]
        [parameter()]
        [string]$UntilVersion,
        [switch]$ShowInBrowser
    )
    
    begin {
        
        
    }
    
    process {
        $client = [System.Net.WebClient]::new()
        $History = $client.DownloadString("https://raw.githubusercontent.com/eXpandFramework/eXpand.lab/history/ReleaseNotesHistory/History.csv") | ConvertFrom-Csv 
        $result = $History | ForEach-Object {
            [PSCustomObject]@{
                Release = [version]$_.Release
                Issues  = $_.Issues.split(",")
                Labels  = $_.Labels.split(",")
                Message = $_.Message
                Sha     = $_.Sha
            }
        } | Where-Object {
            if ($Label) {
                $_.Labels | Where-Object { $Label | Select-String $_ }
            }
            else {
                !$Label
            }
        } | Where-Object {
            if ($SinceVersion) {
                $_.Release -gt $SinceVersion -or $_.release -eq $SinceVersion
            }
            else {
                !$SinceVersion
            }
        } | Where-Object {
            if ($UntilVersion) {
                $_.Release -lt $UntilVersion
            }
            else {
                !$UntilVersion
            }
        } | ForEach-Object {
            [PSCustomObject]@{
                Release = [version]$_.Release
                Issues  = ($_.Issues) -join ", "
                Labels  = $_.Labels -join ", "
                Message = $_.Message
                Sha     = $_.Sha
            }
        }
        if ($ShowInBrowser) {
            $result = $result | ForEach-Object {
                $release = $_.Release
                $message = $_.Message
                $sha = $_.Sha
                [PSCustomObject]@{
                    Release = "<a href='https://github.com/eXpandFramework/eXpand/releases/tag/$release'>$release</a>"
                    Issues  = ($_.Issues | ForEach-Object { "<a href='https://github.com/eXpandFramework/eXpand/issues/$_'>$_</a>" }) 
                    Labels  = $_.Labels | ForEach-Object { "<a href='https://github.com/eXpandFramework/eXpand/labels//$_'>$_</a>" }
                    Message = $message
                    Sha     = "<a href='https://github.com/eXpandFramework/eXpand/commit/$sha'>$sha</a>"
                }   
            }
            Add-Type -AssemblyName System.Web
            $file = "$([System.IO.Path]::GetTempPath())\$([Guid]::NewGuid()).html"
            $html = [System.Web.HttpUtility]::HtmlDecode(($result | ConvertTo-Html))
            $html | Out-File $file
            & $file
        }
        else {
            $result | Format-Table
        }
    }
    
    end {
    }
}