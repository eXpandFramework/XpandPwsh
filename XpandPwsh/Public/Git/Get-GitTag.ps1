function Get-GitTag {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$repoGitUrl,
        [switch]$Last,
        [string]$nameMatch
    )
    
    begin {
        if ($nameMatch -and $nameMatch -ne ".*"){
            $nameMatch=[regex]::Escape($nameMatch)
        }
    }
    
    process {
        $tags=git ls-remote --tags $repoGitUrl|ForEach-Object{
            [PSCustomObject]@{
                Sha = "$_".Substring(0,$_.IndexOf("refs")).Trim()
                Name= $_.Substring($_.LastIndexOf("/")+1)
            }
        }
        if ($Last){
            $tags=$tags|Select-Object -Last 1
        }
        if ($nameMatch){
            $tags=$tags|Where-Object{$_ -match $nameMatch}
        }
        $tags
    }
    
    end {
    }
}