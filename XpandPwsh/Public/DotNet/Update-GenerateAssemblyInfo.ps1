function Update-GenerateAssemblyInfo {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [bool]$value=$false
    )
    
    begin {
    }
    
    process {
        Update-ProjectProperty $CSProj GenerateAssemblyInfo "$value".ToLower()
    }
    
    end {
    }
}