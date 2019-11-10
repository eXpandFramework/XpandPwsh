
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
        $paketReferences=Invoke-PaketShowInstalled -Project $Path
        if ($packageReferences -and $packageReferences){
            $packageReferences
            throw "$Path has packageReferences and paketreferences"
        }
        $paketReferences|ForEach-Object{
            [PSCustomObject]@{
                Include = $_.Id
                id = $_.Id
                Version=$_.Version
            }
        }
    }
    
    end {
        
    }
}