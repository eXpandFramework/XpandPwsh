
function Write-HostFormatted {
    [CmdLetTag()]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
        [System.Object] $Object,
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor,
        [Alias('bg')] [System.ConsoleColor] $BackgroundColor,
        [validateSet("Bold", "Inverted","Underline","Frame")]
        [string[]]$Style,
        [Alias('nnl')] [switch] $NoNewline,
        [switch]$Section,
        [switch]$AnsiColors,
        [int]$Indent,
        [ValidateSet("Output","Verbose")]
        [string]$Stream="Output"

    )    
    begin {
        if ($Section){
            if (!$ForegroundColor){
                $ForegroundColor="Green"
            }
            $Style="Frame"   
        }
        $color=@{}
        if ($ForegroundColor){
            $color.Add("ForegroundColor",$ForegroundColor)
        }
        if ($BackGroundColor){
            $color.Add("BackGroundColor",$BackGroundColor)
        }
    }
    process {
        
        if ($env:Build_DefinitionName ){  
            if ($ForegroundColor -eq "Blue"){
                $directive="##[command]"    
            }
            elseif ($ForegroundColor -eq "Green"){
                $directive="##[section]"    
            }
            elseif ($ForegroundColor -eq "Magenta"){
                $directive="##[debug]"    
            }
            elseif ($ForegroundColor -eq "Yellow"){
                $directive="##[warning]"    
            }
            elseif ($ForegroundColor -eq "red"){
                $directive="##[error]"    
            }
            $directive+=$Object
            if ($Style -eq "Frame"){
                $directive|ConvertTo-FramedText -Stream $Stream @color
            }
            else {
                $directive
            }
            return
        }
        
        $fc=$ForegroundColor
        $code = GetAnsiCode $fc
        $code += GetAnsiCode $BackgroundColor 10
        if ($Style -ne "Frame"){
            $code += ($Style | ForEach-Object { GetAnsiCode $_ }) -join ""
        }else{
            $Object=$Object|ConvertTo-framedtext -Stream $Stream @color
        }
        if ($AnsiColors){
            $Object|ForEach-Object{
                $newcode = "$($code)$_"
                $newcode += GetAnsiCode "Default"
                $newcode
            }
        }
        else{

            $Object|ForEach-Object{
                $prefix=$null
                for ($i = 0; $i -lt $Indent; $i++) {
                    $prefix+="  "
                }
                $prefix+=$_
                if ($Style -eq "Underline"){
                    $prefix=ConvertTo-FramedText $prefix -NoRoof -char "-" -Stream $Stream @color
                }
                $prefix|ForEach-Object{
                    
                    if ($Stream -eq "Verbose"){
                        Write-Verbose $_ @color
                    }
                    else{
                        Write-Host $_ @color 
                    }
                }
            }
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
