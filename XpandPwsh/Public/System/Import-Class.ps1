function Import-Class {
    [CmdletBinding()]
    param (
        # Imports classes from a powershell module
        [Parameter(Mandatory)]
        [string]
        $ModuleName
    )
    
    begin {
        
    }
    
    process {
        & (Get-Module $ModuleName) {[c]::new()}
    }
    
    end {
        
    }
}