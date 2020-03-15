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
    }
    
    process {
        Microsoft.PowerShell.Utility\Write-Verbose $Message -Verbose
    }
    
    end {
        $host.PrivateData.VerboseBackgroundColor=$verboseBackgroundColor
        $host.PrivateData.VerboseForegroundColor=$verboseForegroundColor       
    }
}