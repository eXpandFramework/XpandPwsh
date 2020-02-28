function Get-XpandReleaseArtifact {
    [CmdLetTag()]
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