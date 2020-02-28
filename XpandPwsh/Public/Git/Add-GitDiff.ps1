
function Add-GitDiff {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(Mandatory)]
        [string[]]$ExlcudeWildcard
    )
    
    begin {
        
    }
    
    process {
        git diff --name-only|Where-Object{
            $path=$_
            !($ExlcudeWildcard|Where-Object{$path -like $_}|Select-Object -first 1)
        }|ForEach-Object{
            git add $_
        }       
    }
    
    end {
        
    }
}