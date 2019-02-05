using namespace System
using namespace System.Reflection
using namespace System.Text.RegularExpressions
using namespace System.IO
using namespace System.Collections.Generic
Install-NugetCommandLine
Install-NugetSearch
function Get-DxNugets{
    param(
        [parameter(Mandatory)]
        [string]$version
    )
    (new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv")|ConvertFrom-csv
}
function Update-NugetPackages{
    [cmdletbinding()]
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$sourcePath,
        [parameter(Mandatory)]
        [string]$filter,
        [string]$repositoryPath
    )
    $sources=Get-PackageSourceLocations Nuget
    $packages=New-Object "System.Collections.Generic.Dictionary[System.String,System.String]"
    Get-ChildItem $sourcePath packages.config -Recurse|ForEach-Object {
        $packageConfigPath=$_.FullName
        [xml]$packageConfig = Get-Content $packageConfigPath
        $packageConfig.packages.package|Where-Object{$_.id -like $filter}|ForEach-Object{
            $packageId=$_.Id
            if (!$packages.ContainsKey($packageId)){
                $metadata=Get-NugetPackageSearchMetadata -Name $packageId -Sources $sources
                $packages.Add($packageId,$metadata.Version.ToString())
            }
            $version=$packages[$packageId]
            if ($_.Version -ne $version){
                Write-host "Updating $packageId in $packageConfigPath" -f "Blue"
                & Nuget Update $packageConfigPath -id $packageId -source $($sources -join ";") -RepositoryPath $repositoryPath  -Version $version -verbosity detailed
            }
        }
    }
}
function Get-PackageSourceLocations($providerName){
    $(Get-PackageSource|Where-object{
        !$providerName -bor ($_.ProviderName -eq $providerName) 
    }|Select-Object -ExpandProperty Location -Unique|Where-Object{$_ -like "http*" -bor (Test-Path $_)})
}
function Format-Nuget(
    [string]$item) {

    $strings = $item.Split(" ")
    [PSCustomObject]@{
        Name    = $strings[0]
        Version = new-object System.Version ($strings[1])
    }
}


function Remove-Nuget([parameter(Mandatory)][string]$id,$path=(Get-Location)) {
    Get-ChildItem $path *.csproj -Recurse | ForEach-Object { $_.FullName } | Update-SpecificVersions -filter $id
    push-location $path
    Clear-ProjectDirectories 
    pop-location
}

function Install-NugetCommandLine{
    Install-Chocolatey
    cinst NuGet.CommandLine
}

function Get-NugetPackageAssembly {
    [CmdletBinding(DefaultParameterSetName="nupkgPath")]
    param (
        [parameter(Mandatory,ParameterSetName="nupkgPath")]
        [string]$nupkgPath,
        [parameter(ParameterSetName="nupkgPath")]
        [string]$flattenPath="$env:TEMP\$([System.Guid]::NewGuid())",
        [parameter(ParameterSetName="nupkgPath")]
        [switch]$keepFlatten,
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="package")]
        [string]$package
    )
    begin{
        if ($PSCmdlet.ParameterSetName -eq "package"){
            $source=Get-PackageSource|Where-object{$_.Location -eq "https://api.nuget.org/v3/index.json"}
            if (!$source){
                throw "add https://api.nuget.org/v3/index.json"
            }
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq "package"){
            $p=Get-Package $package -ErrorAction SilentlyContinue -ProviderName Nuget 
            if (!$p){
                Write-Verbose "Installing $_"
                Install-Package $package -ProviderName Nuget -Scope CurrentUser -Force -SkipDependencies -Source $source.Name |Write-Verbose
                $p=Get-Package $package -ProviderName Nuget
            }
            $nupkg=get-item $p.Source
            Get-NugetPackageAssembly -nupkgPath $nupkg.DirectoryName -flattenPath "$($nupkg.DirectoryName)\$($p.Name)" -keepFlatten 
        }
        else{
            if ($flattenPath -eq $nupkgPath){
                throw "same paths"
            }
            New-Item $flattenPath -ItemType Directory -Force|Out-Null
            Write-Verbose "Move packages to $flattenPath and rename to zip"
            Get-ChildItem $nupkgPath *.nupkg |ForEach-Object{
                $newName=([Path]::ChangeExtension($_.Name, ".zip"))
                if (!(Test-path "$flattenPath\$newName")){
                    Copy-Item $_.FullName -Destination $flattenPath -Force
                    Rename-Item -path "$flattenPath\$($_.Name)" -NewName  $newName -Force
                }
            }
            Write-Verbose "Expand archives from $flattenPath"
            Get-ChildItem $flattenPath *.zip|ForEach-Object{
                Expand-Archive -DestinationPath "$($_.DirectoryName)\$($_.BaseName)" -Path $_.FullName -Force 
                if (!$keepFlatten){
                    Remove-Item $_.FullName -Force
                }
            }
            Write-Verbose "Creating Objects "
            $packages=Get-ChildItem $flattenPath|ForEach-Object{
                $version = [Regex]::Match($_.BaseName, "[\d]*\.[\d]*\.[\d]*(\.[\d]*)?$").Value.Trim(".")
                $packageName = $_.BaseName.Replace($version, "").Trim(".").Trim(".v")
                Get-ChildItem $_.FullName *.dll -Recurse|ForEach-Object{
                    [PSCustomObject]@{
                        Package = $packageName
                        Version  = $version
                        Assembly = $_
                        Framework = $_.Directory.Name
                    }
                }
            }|Sort-Object $_.Package
            if (!$keepFlatten){
                [Directory]::Delete($flattenPath,$true)|Out-Null        
            }
            $packages
        }
        
    }
    
    end {
    }
}

function Install-NugetSearch{
    $nugetSearch=Get-Module NugetSearch -ListAvailable
    if (!$nugetSearch){
        Write-Host "Installing Nuget-Search"
        $installationPath="$($env:PSModulePath -split ";"|where-object{$_ -like "$env:USERPROFILE*"}|Select-Object -Unique)\NugetSearch"
        # $installationPath="$PSScriptRoot\NugetSearch"
        New-Item $installationPath -ItemType Directory -Force
        $code=Get-Content "$PSScriptRoot\NugetSearch.cs" -Raw
        New-Assembly -AssemblyName NugetSearch -Code $code -Packages @("NuGet.Protocol.Core.v3","PowerShellStandard.Library") -path $installationPath
    }
}


function Use-NugetAssembly {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$packageName,
        [string]$framework="*"
    )
    
    begin {
    }
    
    process {
        Get-NugetPackageAssembly -package $packageName |where-object{$_.Framework -like $framework}|ForEach-Object{
            [Assembly]::LoadFile($_.Assembly.FullName)
        }
    }
    
    end {
    }
}