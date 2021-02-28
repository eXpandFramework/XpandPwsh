function Install-NpmPackage {
    [CmdletBinding()]
    [CmdLetTag(("#npm","#nodejs"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Package
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        try {
            $nodeExist=node -v
        }
        catch {
            
        }
        if (!$nodeExist){
            Install-ChocoPackage nodejs
        }
        # Invoke-Script{((npm init -y) -join "`r`n")|Write-Verbose}
    }
    
    process {
        if (!(npm list -g|select-string $Package)){
            Invoke-Script{((npm install -g $Package) -join "`r`n")}
        }
    }
    
    end {
        
    }
}