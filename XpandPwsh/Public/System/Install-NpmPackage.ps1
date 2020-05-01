function Install-NpmPackage {
    [CmdletBinding()]
    [CmdLetTag(("#npm","#nodejs"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Package
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Install-ChocoPackage nodejs
        Invoke-Script{npm init -y}
    }
    
    process {
        if (!(npm list -g|select-string $Package)){
            Invoke-Script{npm install -g $Package}
        }
    }
    
    end {
        
    }
}