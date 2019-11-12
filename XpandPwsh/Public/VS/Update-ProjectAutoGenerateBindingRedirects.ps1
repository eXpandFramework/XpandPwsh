function Update-ProjectAutoGenerateBindingRedirects {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [bool]$value=$true
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj AutoGenerateBindingRedirects "$value".ToLower()
    }
    
    end {
    }
}