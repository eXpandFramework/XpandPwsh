function Update-ProjectAutoGenerateBindingRedirects {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
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