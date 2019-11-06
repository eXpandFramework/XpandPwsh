function Get-PaketPath {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $directoryName=(Get-Item (Get-Module XpandPwsh -ListAvailable).Path).DirectoryName
        "$directoryName\private\.paket\paket.exe"
    }
    
    end {
        
    }
}