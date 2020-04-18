function Start-SqlLocalDB {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        sqllocaldb start MSSQLLocalDB
    }
    
    end {
        
    }
}