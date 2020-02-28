function ConvertTo-Object {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
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