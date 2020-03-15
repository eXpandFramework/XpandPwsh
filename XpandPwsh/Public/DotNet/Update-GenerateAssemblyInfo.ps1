function Update-GenerateAssemblyInfo {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [bool]$value=$false
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Update-ProjectProperty $CSProj GenerateAssemblyInfo "$value".ToLower()
    }
    
    end {
    }
}