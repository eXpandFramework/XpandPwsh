function ConvertTo-Dictionary {
    [CmdletBinding()]
    param (
        [Parameter(  
            Position = 0,   
            Mandatory = $true,   
            ValueFromPipeline = $true,  
            ValueFromPipelineByPropertyName = $true  
        )] [object] $Object ,
        [parameter(Mandatory,Position=1)]
        [string]$KeyPropertyName,
        [parameter(Mandatory)]
        [scriptblock]$ValueSelector,
        [switch]$Force
    )
    
    begin {
        $output = @{}
    }
    
    process {
        $key=$Object.($KeyPropertyName)
        if (!$Force){
            if (!$output.ContainsKey($key)){
                $output.add($key,(& $ValueSelector $_))
            }
        }
        else{
            $output.add($key,(& $ValueSelector $_))
        }
        
    }
    
    end {
        $output
    }
}
