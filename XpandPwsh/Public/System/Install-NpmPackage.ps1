function Install-NpmPackage {
    [CmdletBinding()]
    [CmdLetTag(("#npm","#nodejs"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Package
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(node -v)){
            Install-ChocoPackage nodejs
        }
    }
    
    process {
        if (!(npm list -g|select-string $Package)){
            Invoke-Script{((npm install -g $Package) -join "`r`n")|Write-Verbose}
        }
    }
    
    end {
        
    }
}