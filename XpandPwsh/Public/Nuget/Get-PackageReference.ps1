
function Get-PackageReference {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [string]$Path = ".",
        [switch]$PrivateAssets
    )
    
        
    [xml]$Proj = Get-XmlContent $Path
    $packageReferences = $Proj.project.ItemGroup.PackageReference | Where-Object { $_ } | Where-Object {
        !$PrivateAssets -or !$_.PrivateAssets
    }
    $packageReferences
    $refsPath = "$((Get-Item $Path).DirectoryName)\paket.references"
    if (Test-Path $refsPath) {
        $ipa = @{
            Project       = $path
            PrivateAssets = $PrivateAssets
        }
        Push-Location (Get-Item $refsPath).DirectoryName
        $installedPakets = Invoke-PaketShowInstalled @ipa
        Pop-Location
        $paketRefs = Get-Content $refsPath | ForEach-Object {
            $ref = $_
            $installedPakets | Where-Object { $_.Id -eq $ref }
        } | ForEach-Object {
            [PSCustomObject]@{
                Include = $_.Id
                id      = $_.Id
                Version = $_.Version
                Paket   = $true
            }        
        }
        $paketRefs
    }      
    
    if ($paketRefs -and $packageReferences) {
        throw "$Path has packageReferences and paketreferences"
    }
}