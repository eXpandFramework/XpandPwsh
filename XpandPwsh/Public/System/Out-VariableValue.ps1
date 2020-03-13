function Out-VariableValue {
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
            Write-Verbose "$($v.Name) :"
            $value|Out-Verbose -PassThrough:$passthrough
        }
        else{
            "$($v.Name) :$value"|Out-Verbose -PassThrough:$passthrough
        }
    }
    
    end {
        
    }
}