function Get-XpandRelease {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [ValidateSet("All","All.Lab","eXpand","eXpand.lab","Reactive.XAF")]
        [string]$Type,
        [parameter(ValueFromPipeline)]
        [string]$NameMatch=".*"        
    )
    
    begin {
    }
    
    process {
        if ($Type -notlike "All*"){
            Get-GitTag (Get-XpandRepository $Type -Uri) -nameMatch $NameMatch
        }
        else{
            $c=[System.Net.WebClient]::new()
            if ($Type -eq "All.Lab"){
                $repo=".lab"
            }
            Get-GitTag (Get-XpandRepository "eXpand$repo" -Uri) -nameMatch $NameMatch|ForEach-Object{
                $deps=$c.DownloadString("https://raw.githubusercontent.com/eXpandFramework/eXpand$repo/$($_.Sha)/paket.dependencies")
                $regex = [regex] '(?imn)Xpand\.XAF\.Win\.All (?<v>.*)'
                $result = $regex.Match($deps).Groups["v"].Value;
                [PSCustomObject]@{
                    Xpand = $_.Name
                    XAF=$result
                }
            }
        }
    }
    
    end {
    }
}