function Clear-NugetCache {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [ValidateSet("XpandPackages","DevExpress")]
        [string[]]$Filter,
        [switch]$SkipVersionConverter,
        [parameter(ParameterSetName="paket")]
        [switch]$Recurse
    )
    
    if ($Filter) {
        $path = (Get-NugetInstallationFolder GlobalPackagesFolder)
        if ("XpandPackages" -in $Filter){
            $match=@("Xpand*","eXpand*","*.Xpand")
        }
        if ("DevExpress" -in $Filter){
            $match+=@("DevExpress*","DevExtreme*")
        }
        if (Test-Path ".\packages"){
            RemovePackages ".\packages" $SkipVersionConverter  $match
        }
        if (Test-Path $path){
            RemovePackages $path $SkipVersionConverter $match
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
        $SkipVersionConverter,
        $Match
    )
    
    $folders = Get-ChildItem $path 
    if (Test-Path "$path/packages"){
        $folders+=Get-ChildItem "$path/packages"
    }
    $folders | Where-Object {
        if (!($SkipVersionConverter -and $_.BaseName -notlike "*VersionConverter")) {
            $baseName=$_.BaseName
            $match|Where-Object{$baseName -like $_}
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
            $baseName=$_.BaseName
            $match|Where-Object{$baseName -like $_}
        }
    } | Remove-Item -Recurse -Force 
}

