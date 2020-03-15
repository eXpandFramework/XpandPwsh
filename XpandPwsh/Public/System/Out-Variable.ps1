function Out-Variable {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline,ParameterSetName="Name")]
        [string]$VariableName,
        [parameter(ParameterSetName="Name")]
        [Switch]$PassThrough,
        [parameter(ParameterSetName="instance",ValueFromPipeline)]
        [psvariable]$Variable
    )
    
    begin {
        
    }
    
    process {
        $v=$Variable
        if (!$v){
            $v=Get-Variable $VariableName
        }
        $value=$v.Value
        if ($value.count -gt 1){
            Write-Verbose "$($v.Name) :" -Verbose
            $value|Out-Verbose -PassThrough:$passthrough
        }
        else{
            $msg="$($v.Name) :"
            if ($value){
                $msg+=$value
            }
            $msg|Out-Verbose -PassThrough:$passthrough
        }
    }
    
    end {
        
    }
}