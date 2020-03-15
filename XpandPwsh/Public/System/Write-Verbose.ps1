function Write-Verbose {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message,
        [Alias('fg')] [System.ConsoleColor] $ForegroundColor,
        [Alias('bg')] [System.ConsoleColor] $BackgroundColor
    )
    
    begin {
        $verboseForegroundColor=$host.PrivateData.VerboseForegroundColor
        $verboseBackgroundColor=$host.PrivateData.VerboseBackgroundColor
        if ($ForegroundColor){
            $host.PrivateData.VerboseForegroundColor=$ForegroundColor
        }
        if ($BackgroundColor){
            $host.PrivateData.VerboseBackgroundColor=$BackgroundColor
        }
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
        }
    }
    
    process {
        $msg=$directive
        $msg+=$Message
        Microsoft.PowerShell.Utility\Write-Verbose $msg -Verbose
    }
    
    end {
        $host.PrivateData.VerboseBackgroundColor=$verboseBackgroundColor
        $host.PrivateData.VerboseForegroundColor=$verboseForegroundColor       
    }
}