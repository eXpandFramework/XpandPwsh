function Get-GitLastSha {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$repoGitUrl
    )
    
    begin {
    }
    
    process {
        (git ls-remote $repoGitUrl|Where-Object {$_ -like "*HEAD*"}|Select-Object -first 1).Replace("HEAD", "").Trim("")
    }
    
    end {
    }
}