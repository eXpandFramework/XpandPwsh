function Out-Verbose {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        $VerboseInput,
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor,
        [Alias('bg')] [System.ConsoleColor] $BackgroundColor,
        [Switch]$PassThrough
    )
    
    begin {
        $color=@{}
        if ($ForegroundColor){
            $color.Add("ForegroundColor",$ForegroundColor)
        }
        if ($BackGroundColor){
            $color.Add("BackGroundColor",$BackGroundColor)
        }
        $items=@()
    }
    
    process {
        $items+=$VerboseInput
    }
    
    end {
        $items | Out-String -Stream|Where-Object{$_} | Write-Verbose @color 
    }
}