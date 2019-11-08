
function Get-PackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        [xml]$Proj=Get-Content $Path
        $packageReferences=$Proj.project.ItemGroup.PackageReference|Where-Object{$_}
        $paketReferences=Get-PaketPackageReference (Get-Item $Path).DirectoryName
        if ($packageReferences -and $packageReferences){
            $packageReferences
            throw "$Path has packageReferences and paketreferences"
        }
        $packageReferences
        $paketReferences
    }
    
    end {
        
    }
}