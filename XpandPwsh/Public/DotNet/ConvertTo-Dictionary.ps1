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
        [switch]$Force,
        [switch]$Ordered
    )
    
    begin {
        $output = @{}
        if ($Ordered){
            $output=[ordered]@{}
        }
    }
    
    process {
        $key=$Object.($KeyPropertyName)
        if (!$Force){
            if ($output.Keys -notcontains $key){
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
