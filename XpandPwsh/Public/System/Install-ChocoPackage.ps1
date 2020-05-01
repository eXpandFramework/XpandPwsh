function Install-ChocoPackage {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Package
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Install-Chocolatey
    }
    
    process {
        if (!(Get-ChocoPackage $Package)){
            choco install $Package
        }
    }
    
    end {
        
    }
}