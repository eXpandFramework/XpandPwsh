function Write-HostFormatted {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [System.Object] $Object,
        [validateSet("Green","Blue","Purple","Yellow","Red")]
        [Alias('fg')] [string] $ForegroundColor,
        [validateSet("Green","Blue","Purple","Yellow","Red")]
        [Alias('bg')] [string] $BackgroundColor,
        [validateSet("Bold", "Inverted","Underline","Frame")]
        [string[]]$Style,
        [Alias('nnl')] [switch] $NoNewline
    )    
    begin {
    }
    process {
        if ($env:Build_DefinitionName ){
            $directive="##[section]"    
            if ($ForegroundColor -eq "Blue"){
                $directive="##[command]"    
            }
            elseif ($ForegroundColor -eq "Purple"){
                $directive="##[debug]"    
            }
            elseif ($ForegroundColor -eq "Yellow"){
                $directive="##[warning]"    
            }
            elseif ($ForegroundColor -eq "red"){
                $directive="##[error]"    
            }
            else{
                $directive=$null
            }
            $directive+=$Object
            if ($Style -eq "Frame"){
                $directive|ConvertTo-FramedText
            }
            else {
                $directive
            }
            return
        }
        $code = GetAnsiCode $ForegroundColor
        $code += GetAnsiCode $BackgroundColor 10
        $code += ($Style | ForEach-Object { GetAnsiCode $_ }) -join ""
        $code += $Object
        $code += GetAnsiCode "Default"
        if ($Style -eq "Frame"){
            $code|ConvertTo-FramedText
        }
        else {
            $code
        }
        
    }
    end {
 
    }
}
function GetAnsiCode($name, $offSet) {
    if ($name) {
        $ansiCodes = @{Default = 0; Bold = 1; Underline = 4; Inverted = 7; Black = 30; Red = 31; Green = 32; Yellow = 33; Blue = 34; Magenta = 35; Cyan = 36; White = 37; BrightBlack = 90; BrightRed = 91; BrightGreen = 92; BrightYellow = 92; BrightBlue = 94; BrightMagenta = 95; BrightCyan = 96; BrightWhite = 97 }
        $esc = "$([char]27)"
        $code = $ansiCodes["$name"] + $offSet
        "$esc[$code`m"
    }
}
