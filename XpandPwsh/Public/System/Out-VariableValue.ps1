function Out-VariableValue {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [string]$VariableName,
        [Switch]$PassThrough
    )
    
    begin {
        
    }
    
    process {
        $value=(Get-Variable $VariableName).Value
        if ($value.count -gt 1){
            Write-Verbose "$VariableName :"
            (Get-Variable $VariableName).Value|Out-Verbose -PassThrough:$passthrough
        }
        else{
            "$VariableName :$value"|Out-Verbose -PassThrough:$passthrough
        }
    }
    
    end {
        
    }
}