function ConvertTo-Dictionary {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [Parameter(Position = 0,Mandatory,ValueFromPipeline)] 
        [object] $Object ,
        [parameter(Mandatory,Position=1)]
        [string]$KeyPropertyName,
        [string]$ValuePropertyName,
        # [parameter(Mandatory)]
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
                if ($ValueSelector){
                    $output.add($key,(& $ValueSelector $Object))
                }
                else{
                    $value=$Object.($ValuePropertyName)
                    $output.add($key,$value)
                }
                
            }
        }
        else{
            $output.add($key,(& $ValueSelector $Object))
        }
        
    }
    
    end {
        $output
    }
}
