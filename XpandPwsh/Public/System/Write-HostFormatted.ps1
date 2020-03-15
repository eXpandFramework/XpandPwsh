
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
        $verboseForegroundColor=$host.PrivateData.VerboseForegroundColor
        $verboseBackgroundColor=$host.PrivateData.VerboseBackgroundColor
        if ($Stream -eq "Verbose"){
            if ($ForegroundColor){
                $host.PrivateData.VerboseForegroundColor=$ForegroundColor
            }
            if ($BackgroundColor){
                $host.PrivateData.VerboseBackgroundColor=$BackgroundColor
            }
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
            elseif ($ForegroundColor -eq "Purple"){
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
                $directive|ConvertTo-FramedText -Stream $Stream
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
            $Object=$Object|ConvertTo-framedtext -Stream $Stream
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
                    $prefix=ConvertTo-FramedText $prefix -NoRoof -char "_" -Stream $Stream
                }
                $prefix|ForEach-Object{
                    $a=@{
                        Object=$_
                    }
                    if ($ForegroundColor){
                        $a.Add("ForegroundColor",$ForegroundColor)
                    }
                    if ($BackGroundColor){
                        $a.Add("BackGroundColor",$BackGroundColor)
                    }
                    if ($Stream -eq "Verbose"){
                        Write-Verbose $_ -Verbose
                    }
                    else{
                        Write-Host @a 
                    }
                }
            }
        }
    }
    end {
        $host.PrivateData.VerboseBackgroundColor=$verboseBackgroundColor
        $host.PrivateData.VerboseForegroundColor=$verboseForegroundColor
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
