function Find-History {
    [CmdletBinding()]
    [alias("fxh")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Text
    )
    
    begin {
        
    }
    
    process {
        Get-Content (Get-PSReadlineOption).HistorySavePath|select-string $text
    }
    
    end {
        
    }
}