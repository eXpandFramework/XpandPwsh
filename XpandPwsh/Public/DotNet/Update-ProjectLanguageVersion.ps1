function Update-ProjectLanguageVersion {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
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