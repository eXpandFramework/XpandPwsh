
function Get-PackageReference {
    [CmdletBinding()]
    param (
        [string]$Path = "."
    )
    
        
    [xml]$Proj = Get-Content $Path
    $packageReferences = $Proj.project.ItemGroup.PackageReference | Where-Object { $_ }
        
    if ($packageReferences -and $packageReferences) {
        $packageReferences
        throw "$Path has packageReferences and paketreferences"
    }
    $refsPath = "$((Get-Item $Path).DirectoryName)\paket.references"
    if (Test-Path $refsPath) {
        $installedPakets = Invoke-PaketShowInstalled -Project $Path
        Get-Content $refsPath | ForEach-Object {
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
}