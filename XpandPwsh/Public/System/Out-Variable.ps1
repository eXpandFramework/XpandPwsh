function Out-Variable {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline,ParameterSetName="Name")]
        [string]$VariableName,
        [parameter(ParameterSetName="Name")]
        [Switch]$PassThrough,
        [parameter(ParameterSetName="instance",ValueFromPipeline)]
        [psvariable]$Variable,
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor=[System.ConsoleColor]::Magenta,
        [Alias('bg')] [System.ConsoleColor] $BackgroundColor
    )
    
    begin {
        $color=@{}
        if ($ForegroundColor){
            $color.Add("ForegroundColor",$ForegroundColor)
        }
        if ($BackGroundColor){
            $color.Add("BackGroundColor",$BackGroundColor)
        }
    }
    
    process {
        $v=$Variable
        if (!$v){
            $v=Get-Variable $VariableName
        }
        $value=$v.Value
        if ($value.count -gt 1){
            Write-Verbose "$($v.Name) :" @color
            $value|Where-Object{$_}|Out-Verbose -PassThrough:$passthrough @color
        }
        else{
            $msg="$($v.Name) :"
            if ($value){
                $msg+=$value
            }
            $msg|Out-Verbose -PassThrough:$passthrough @color
        }
    }
    
    end {
        
    }
}