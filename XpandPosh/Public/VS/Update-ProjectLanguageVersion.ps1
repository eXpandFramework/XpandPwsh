function Update-ProjectLanguageVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj LangVersion latest
    }
    
    end {
    }
}