function Approve-LastExitCode {
    [CmdletBinding()]
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