function Clear-NugetCache {
    [CmdletBinding()]
    param (
        [ValidateSet("XpandPackages")]
        $Filter,
        [switch]$SkipVersionConverter,
        [parameter(ParameterSetName="paket")]
        [switch]$Recurse
    )
    
    if ($Filter) {
        $path = (Get-NugetInstallationFolder GlobalPackagesFolder)
        if (Test-Path ".\packages"){
            RemovePackages ".\packages" $SkipVersionConverter    
        }
        RemovePackages $path $SkipVersionConverter
    }
    else { 
        if (!$SkipPaket) {
            Invoke-PaketClearCache 
        }
        & (Get-NugetPath) locals all -clear
        dotnet tool restore
    }
}

function RemovePackages {
    param (
        $Path,
        $SkipVersionConverter
    )
    
    $folders = Get-ChildItem $path 
    if (Test-Path "$path/packages"){
        $folders+=Get-ChildItem "$path/packages"
    }
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

