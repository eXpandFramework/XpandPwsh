function ConvertTo-FramedText {
    [CmdletBinding()]
    [CmdLetTag()]
    param(
        [Parameter(Mandatory = $true, Position = 0, valueFromPipeline = $true)]
        [string]$stringIN,
        [string]$char = "-",
        [switch]$NoRoof,
        [ValidateSet("Output","Verbose")]
        [string]$Stream="Output",
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor,
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
        $writer={
            param($text)
            if ($Stream -eq "Output"){
                $text
            }
            else{
                Write-Verbose $text -Verbose @color
            }
        }
    }
    
    process {
        $underLine = $char * $stringIn.length
        if (!$NoRoof){
            & $writer $underLine
        }
        
        & $writer $stringIn
    
        & $writer $underLine
            
    }
    
    end {
        
    }
}
