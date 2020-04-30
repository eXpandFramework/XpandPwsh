function Install-ChocoPackage {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Package
    )
    
    begin {
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