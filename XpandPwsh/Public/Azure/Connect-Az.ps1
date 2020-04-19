function Connect-Az {
    [CmdLetTag("#Azure")]
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$ApplicationSecret,
        [parameter(Mandatory)]
        [string]$AzureApplicationId,
        [parameter(Mandatory)]
        [string]$AzureTenantId
    )
    
    begin {
        . $XpandPwshPath\Private\InstallAz.ps1
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $azurePassword = ConvertTo-SecureString $ApplicationSecret -AsPlainText -Force
        $psCred = New-Object System.Management.Automation.PSCredential($AzureApplicationId , $azurePassword)
        Connect-AzAccount -Credential $psCred -TenantId $azureTenantId  -ServicePrincipal
    }
    
    end {
        
    }
}
