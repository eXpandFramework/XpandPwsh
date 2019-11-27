function Remove-VersionConverterFlags {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $mainCache="$env:USERPROFILE\.nuget\packages"
        $items=Get-ChildItem $mainCache "*DoNotDelete*" -Recurse
        $items|Remove-Item -Force -Recurse
    }
    
    end {
        
    }
}