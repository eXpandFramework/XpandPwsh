function Update-AppendTargetFrameworkToOutputPath {
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
        Update-ProjectProperty $CSProj AppendTargetFrameworkToOutputPath "$value".ToLower()
    }
    
    end {
    }
}