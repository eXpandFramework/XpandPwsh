Function ConvertTo-FramedText{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, valueFromPipeline = $true)]
        [string]$stringIN,
        [string]$char = "-"
    )

    $underLine = $char * $stringIn.length
    $underLine
    $stringIn

    $underLine

} 