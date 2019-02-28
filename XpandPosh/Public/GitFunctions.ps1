using namespace System
using namespace System.Reflection
using namespace System.Text.RegularExpressions
using namespace System.IO
using namespace System.Collections
using namespace System.Collections.Generic

function Get-GitLastSha {
    [CmdletBinding()]
    param (
        [parammeter(ValueFromPipeline,Mandatory)]
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