function Update-ProjectAutoGenerateBindingRedirects {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj AutoGenerateBindingRedirects true
    }
    
    end {
    }
}