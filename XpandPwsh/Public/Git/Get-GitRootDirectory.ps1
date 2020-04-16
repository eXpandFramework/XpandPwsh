function Get-GitRootDirectory {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        [parameter(ValueFromPipeline)]
        [System.Management.Automation.PathInfo]$Path=(Get-Location)
    )
    
    begin {
        
    }
    
    process {
        Get-Item (git rev-parse --show-toplevel)
    }
    
    end {
        
    }
}