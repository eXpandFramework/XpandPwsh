function Update-ProjectCopyRight {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [parameter(Mandatory)]
        [string]$CopyRight    
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Update-ProjectProperty $CSProj Copyright $CopyRight
    }
    
    end {
    }
}