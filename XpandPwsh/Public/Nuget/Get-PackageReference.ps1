
function Get-PackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        [xml]$Proj=Get-Content $Path
        $Proj.project.ItemGroup.PackageReference|Where-Object{$_}
        Get-PaketReferences (Get-Item $Path).DirectoryName
    }
    
    end {
        
    }
}