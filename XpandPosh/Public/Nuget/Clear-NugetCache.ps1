function Clear-NugetCache {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
    }
    
    process {
        & (Get-NugetPath) locals all -clear
    }
    
    end {
    }
}