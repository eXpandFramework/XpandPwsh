Function ConvertTo-FramedText{
    [CmdletBinding()]
    [CmdLetTag()]
    param(
        [Parameter(Mandatory = $true, Position = 0, valueFromPipeline = $true)]
        [string]$stringIN,
        [string]$char = "-",
        [switch]$NoRoof,
        [ValidateSet("Output","Verbose")]
        [string]$Stream="Output"
    )
    $writer={
        param($text)
        if ($Stream -eq "Output"){
            $text
        }
        else{
            Write-Verbose $text
        }
    }
    $underLine = $char * $stringIn.length
    if (!$NoRoof){
        & $writer $underLine
    }
    
    & $writer $stringIn

    & $writer $underLine

} 