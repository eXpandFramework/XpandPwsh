function Out-Verbose {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline,Position=0)]
        $VerboseInput,
        [parameter(Position=1)]
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor,
        [parameter(Position=2)]
        [Alias('bg')] [System.ConsoleColor] $BackgroundColor,
        [parameter(Position=3)]
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