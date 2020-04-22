function Test-ChocoInstalled {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        
    )
    
    begin {
    }
    
    process {
        choco -v
    }
    
    end {
    }
}