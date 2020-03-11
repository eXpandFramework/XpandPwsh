function Update-AppendTargetFrameworkToOutputPath {
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
        Update-ProjectProperty $CSProj AppendTargetFrameworkToOutputPath "$value".ToLower()
    }
    
    end {
    }
}