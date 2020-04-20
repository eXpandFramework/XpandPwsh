function Unprotect-SecretVariable {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [string]$t
    )
    
    begin {
        
    }
    
    process {
        Write-Host "$($t[0]) $($t.Substring(1))"
    }
    
    end {
        
    }
}