function Get-XpandPwshDirectoryName {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        (get-item (Get-Module XpandPwsh -ListAvailable).Path).DirectoryName
    }
    
    end {
        
    }
}