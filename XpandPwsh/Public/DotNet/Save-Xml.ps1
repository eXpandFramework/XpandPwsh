function Save-Xml {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [xml]$Owner,
        [parameter(Mandatory,Position =2)]
        [string]$Path
    )
    
    begin {
        
    }
    
    process {
        $Owner.Save($Path)
        Format-Xml -Path $Path
    }
    
    end {
        
    }
}