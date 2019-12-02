function Get-XAFLatestMinors {
    [CmdletBinding()]
    param (
        [string]$Source=$env:DxFeed
    )
    
    begin {
        if (!$env:DxFeed -and !$Source){
            throw "`$env:DxFeed is empty"
        }
    }
    
    process {
        Get-LatestMinorVersion "DevExpress.ExpressApp" -Source $source
    }
    
    end {
        
    }
}