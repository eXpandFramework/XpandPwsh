
function Get-PackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = ".",
        [switch]$PrivateAssets
    )
    
        
    [xml]$Proj = Get-Content $Path
    $packageReferences = $Proj.project.ItemGroup.PackageReference | Where-Object { $_ }|Where-Object{
        !$PrivateAssets -or !$_.PrivateAssets
    }
    $packageReferences
    $refsPath = "$((Get-Item $Path).DirectoryName)\paket.references"
    if (Test-Path $refsPath) {
        $ipa = @{
            Project = $path
            PrivateAssets=$PrivateAssets
        }
        $installedPakets = Invoke-PaketShowInstalled @ipa
        $paketRefs=Get-Content $refsPath | ForEach-Object {
            $ref = $_
            $installedPakets | Where-Object { $_.Id -eq $ref }
        } | ForEach-Object {
            [PSCustomObject]@{
                Include = $_.Id
                id      = $_.Id
                Version = $_.Version
            }        
        }
    }      
    $paketRefs
    if ($paketRefs -and $packageReferences) {
        throw "$Path has packageReferences and paketreferences"
    }
}