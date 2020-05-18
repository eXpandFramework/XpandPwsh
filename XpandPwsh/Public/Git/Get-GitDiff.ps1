
function Get-GitDiff {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(ValueFromPipeline)]
        [string]$Match,
        [System.Management.Automation.PathInfo]$Path=(Get-Location)
    )
    
    begin {
        Push-Location $Path
        $Match=[regex]::Escape($Match)
    }
    
    process {
        
        git diff --name-only|Where-Object{$_ -match $Match}|ForEach-Object{
            "$Path\$_"
        }
        
    }
    
    end {
        Pop-Location
    }
}