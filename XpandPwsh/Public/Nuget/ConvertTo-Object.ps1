function ConvertTo-Object {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        $value
    )
    
    begin {
    }
    
    process {
        $value|Select-Object -First 1 -Property *
    }
    
    end {
    }
}