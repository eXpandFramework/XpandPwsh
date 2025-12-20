function Get-PackageReference {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Path,
        [switch]$PrivateAssets,
        [switch]$AllowBoth
    )
    
    
    begin {
        
    }
    
    process {
        [xml]$Proj = Get-XmlContent $Path
        $packageReferences = $Proj.project.ItemGroup.PackageReference | Where-Object { $_ } | Where-Object {
            !$PrivateAssets -or !$_.PrivateAssets
        }
        # Central Package Management (CPM): Resolve missing versions from Directory.Packages.props
        $cpmRefs = $packageReferences | Where-Object { [string]::IsNullOrWhiteSpace($_.Version) }
        if ($cpmRefs) {
            $dir = (Get-Item $Path).DirectoryName
            $cpmPath = $null
            
            # Search upwards for the configuration file
            while ($dir) {
                $checkPath = Join-Path $dir "Directory.Packages.props"
                if (Test-Path $checkPath) {
                    $cpmPath = $checkPath
                    break
                }
                $parent = Split-Path $dir -Parent
                if ($dir -eq $parent) { break }
                $dir = $parent
            }

            if ($cpmPath) {
                # Parse the props file for version definitions
                [xml]$cpmXml = Get-Content $cpmPath
                $cpmVersions = @{}
                # Handle both Include and Update attributes for PackageVersion
                $cpmXml.Project.ItemGroup.PackageVersion | ForEach-Object {
                    $id = if ($_.Include) { $_.Include } else { $_.Update }
                    if ($id) { $cpmVersions[$id] = $_.Version }
                }

                # Inject resolved versions into the reference objects
                foreach ($ref in $cpmRefs) {
                    if ($cpmVersions.ContainsKey($ref.Include)) {
                        $ref.SetAttribute("Version", $cpmVersions[$ref.Include])
                    }
                }
            }
        }
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
        else{
            $packageReferences
        }
        if ($paketRefs -and $packageReferences) {
            if (!$AllowBoth){
                if (!$Proj.Project.PropertyGroup.AllowPackageReference -or $Proj.Project.PropertyGroup.AllowPackageReference -eq "False"){
                    throw "$Path has packageReferences and paketreferences"
                }
            }
            $packageReferences
        }        
    }
    
    end {
        
    }
}
