function Install-NpmPackage {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Package
    )
    
    begin {
        Install-ChocoPackage nodejs
        npm init -y
    }
    
    process {
        if (!(npm list -g|select-string $Package)){
            npm install -g $Package
        }
    }
    
    end {
        
    }
}