function Approve-LastExitCode {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        if ($lastexitcode){
            throw
        }
    }
    
    end {
        
    }
}