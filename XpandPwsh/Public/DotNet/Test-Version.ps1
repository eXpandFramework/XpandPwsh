function Test-Version {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Version
    )
    
    begin {
    
    }
    
    process {
        [version]$v=$null
        [version]::TryParse($Version,[ref]$v)
    }
    end {
        
    }
}