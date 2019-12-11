function Get-XPwshCommand {
    [CmdletBinding()]
    [alias("gxcm")]
    param (
        [object[]]$ArgumentList
    )
    
    begin {
        
    }
    
    process {
        get-command "*$ArgumentList*" -Module XpandPwsh
    }
    
    end {
        
    }
}