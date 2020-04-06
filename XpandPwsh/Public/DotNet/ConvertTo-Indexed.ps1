function ConvertTo-Indexed {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [object]$Value
    )
    
    begin {
        $index=0
    }
    
    process {
        [PSCustomObject]@{
            Index=$index
            Value = $Value
        }
        $index++
    }
    
    end {
        
    }
}