function Remove-DefaultValueKeys {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [hashtable]$hastable        
    )
    
    begin {
        
    }
    
    process {
        $defaultValueKeys=$hastable.Keys|Where-Object{
            $value=$hastable[$_]
            if ($value -is [array]){
                $value.Count -eq 0
            }
            else{
                !$value
            }
        }
        $defaultValueKeys|ForEach-Object{$hastable.Remove($_)}
        $hastable
    }
    
    end {
        
    }
}