function Get-VersionPart {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [version]$Version,
        [parameter(Mandatory)]
        [ValidateSet("Build")]
        [string]$Part
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}