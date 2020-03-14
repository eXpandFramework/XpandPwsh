function Write-Verbose {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message
    )
    
    begin {
        
    }
    
    process {
        Microsoft.PowerShell.Utility\Write-Verbose $Message -Verbose
    }
    
    end {
        
    }
}