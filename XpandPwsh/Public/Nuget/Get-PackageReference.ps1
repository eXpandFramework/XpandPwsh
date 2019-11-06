
function Get-PackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        $Proj.project.ItemGroup.PackageReference|Where-Object{$_}
        Get-PaketReferences
    }
    
    end {
        
    }
}