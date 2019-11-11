function Clear-NugetCache {
    [CmdletBinding()]
    param (
        [ValidateSet("XpandPackages")]
        $Filter,
        [switch]$SkipVersionConverter,
        [parameter(ParameterSetName="paket")]
        [switch]$SkipPaket,
        [switch]$Recurse
    )
    
    if ($Filter) {
        $path = (Get-NugetInstallationFolder GlobalPackagesFolder)
        RemovePackages $path $SkipVersionConverter
        if (!$SkipPaket) {
            $paketPath = Get-PaketDependenciesPath
            if ($paketPath) {
                RemovePackages "$((Get-Item $paketPath).DirectoryName)\..\packages" $SkipVersionConverter
            }
        }
    }
    else { 
        if (!$SkipPaket) {
            Invoke-PaketClearCache 
        }
        & (Get-NugetPath) locals all -clear
    }
}

function RemovePackages {
    param (
        $Path,
        $SkipVersionConverter
    )
    $folders = Get-ChildItem $path 
    $folders | Where-Object {
        if (!($SkipVersionConverter -and $_.BaseName -notlike "*VersionConverter")) {
            $_.BaseName -like "Xpand*" -or $_.BaseName -like "eXpand*" 
        }
    } | Remove-Item -Recurse -Force 
}

function RemovePackages {
    param (
        $Path,
        $SkipVersionConverter
    )
    $folders = Get-ChildItem $path 
    $folders | Where-Object {
        if (!($SkipVersionConverter -and $_.BaseName -notlike "*VersionConverter")) {
            $_.BaseName -like "Xpand*" -or $_.BaseName -like "eXpand*" 
        }
    } | Remove-Item -Recurse -Force 
}

