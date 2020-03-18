function Update-ProjectNoWarn {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$Project,
        [parameter(Mandatory)]
        [string[]]$NoWarn    
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Update-ProjectProperty -CSProj $Project -PropertyName NoWarn -Value ($NoWarn -join ",")
    }
    
    end {
    }
}