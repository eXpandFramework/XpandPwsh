using namespace System
using namespace System.Reflection
using namespace System.Text.RegularExpressions
using namespace System.IO
using namespace System.Collections
using namespace System.Collections.Generic

function Get-DxNugets{
    param(
        [parameter(Mandatory)]
        [string]$version
    )
    (new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv")|ConvertFrom-csv
}
function Update-NugetPackage{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$SourcePath=".",
        [parameter()]
        [string]$Filter="*"
    )
    $configs=Get-ChildItem $sourcePath packages.config -Recurse|ForEach-Object{
        [PSCustomObject]@{
            Content = [xml]$(Get-Content $_.FullName)
            Config = $_
        }
    }
    $sources=Get-PackageSourceLocations Nuget
    $ids=$configs|ForEach-Object{$_.Content.packages.package.id}|Where-Object{$_ -like $Filter}|Select-Object -Unique 
    $metadatas= $ids|Invoke-Parallel -activityName "Getting latest versions from sources" {(Get-NugetPackageSearchMetadata -Name $_ -Sources $Using:sources)}
    $packages=$configs|ForEach-Object{
        $config=$_.Config
        $_.Content.packages.package|Where-Object{$_.id -like $filter}|ForEach-Object{
            $packageId=$_.Id
            $metadata=$metadatas|Where-object{$_.Metadata.Identity.id -eq $packageId}
            if ($metadata){
                [PSCustomObject]@{
                    Id = $packageId
                    NewVersion = (Get-MetadataVersion $metadata.Metadata).Version
                    Config =$config.FullName
                    Metadata=$metadata
                }
            }
        }
    }|Where-Object{$_.NewVersion -and ($_.Metadata.Version -ne $_.NewVersion)}
    $sortedPackages=$packages|Group-Object Config|ForEach-Object{
        $p=[PSCustomObject]@{
            Packages = ($_.Group|Sort-PackageByDependencies)
        }
        $p
    } 
    
    
    $sortedPackages|Invoke-Parallel -activityName "Update all packages" {
        ($_.Packages|ForEach-Object{
            Write-host "Updating $($_.Id) in $($_.Config) to version $($_.NewVersion) from $($_.Metadata.Source)"
            (& Nuget Update $_.Config -Id $_.Id -Version $($_.NewVersion) -Source "$($_.Metadata.Source)")
        })
    }
}

function Sort-PackageByDependencies {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $psObj
    )
    begin {
        $all=New-Object System.Collections.ArrayList
    }
    
    process {
        $all.Add($psObj)|Out-Null
    }
    
    end {
        $list=New-Object System.Collections.ArrayList
        
        while ($all.Count) {
            $all|ForEach-Object{
                $obj=$_
                $deps=$obj.Metadata.Metadata.DependencySets.Packages|select -ExpandProperty Id
                $exist=$all|select -ExpandProperty Id|where{$deps -contains $_}
                if (!$exist){
                    $list.Add($obj)|out-null
                }
            }
            $list|ForEach-Object{
                $all.Remove($_)|out-null
            }
        }
        $list|ForEach-Object{$_}
    }
}

function Get-MetadataVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [NuGet.Protocol.Core.Types.IPackageSearchMetadata]$metadata
    )
    
    begin {
    }
    
    process {
        $typeName=$metadata.GetType().Name
        $version=$metadata.Version
        if ($typeName -eq "LocalPackageSearchMetadata"){
            $version=$metadata.Identity.Version
        }
        [PSCustomObject]@{
            Name = $metadata.Identity.Id
            Version = $version.ToString()
        }
    }
    
    end {
    }
}

function Get-PackageSourceLocations($providerName){
    $(Get-PackageSource|Where-object{
        !$providerName -bor ($_.ProviderName -eq $providerName) 
    }|Select-Object -ExpandProperty Location -Unique|Where-Object{$_ -like "http*" -bor (Test-Path $_)})
}

function Publish-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$NupkgPath,
        [parameter(Mandatory)]
        [string]$Source,
        [parameter(Mandatory)]
        [string]$ApiKey
    )
    
    begin {
        if (!(Test-Path $NupkgPath)){
            throw "$NupkgPath is not a valid path"
        }
        Get-NugetPackageSearchMetadata -Name "a" -Sources $PSScriptRoot|out-null
    }
    
    process {
        $packages=& Nuget List -source $NupkgPath|convertto-packageobject
        Write-Verbose "Packages found:`r`n$packages"
        $additionalVariables=(("source","ApiKey")|Get-Variable)
        $published=$packages|Select-Object -ExpandProperty Name| Invoke-Parallel -activityName "Getting latest versions from sources" -ImportVariables -ImportFunctions -AdditionalVariables $additionalVariables -ModulesToImport (Get-Module NugetSearch) { 
            (Get-NugetPackageSearchMetadata -Name $_ -Sources $Source|Select-object -ExpandProperty Metadata|Get-MetadataVersion)
        } 
        Write-Verbose "Published packages:`r`n$published"
        $needPush=$packages|Where-Object{
            $p=$_
            $published |Where-Object{
                $_.Name -eq $p.Name -and $_.Version -eq $_.Version
            }
        }
        $needPush|Invoke-Parallel -ActivityName "Publishing Nugets" -AdditionalVariables $additionalVariables -ImportVariables {
            $package="$NupkgPath\$($_.Name).$($_.Version).nupkg"
            Write-Host "Pushing $package in $Source "
            (& nuget Push "$package" $ApiKey -source $Source)
        }
    }
    
    end {
    }
}
function ConvertTo-PackageObject {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$item,
        [switch]$LatestVersion
    )
    
    begin {
        if ($LatestVersion){
            $list=New-Object System.Collections.Arraylist
        }
    }
    
    process {
        
        $strings = $item.Split(" ")
        $psobj=[PSCustomObject]@{
            Name    = $strings[0]
            Version = new-object System.Version ($strings[1])
        }
        if ($LatestVersion){
            $list.Add($psObj)|Out-Null
        }
        else{
            $psobj
        }
    }
    
    end {
        if ($LatestVersion){
            $list|Group-Object -Property Name|ForEach-Object{
                ($_.Group|Sort-Object -Property Version -Descending|Select-Object -First 1)
            }
        }
    }
}



function Remove-Nuget([parameter(Mandatory)][string]$id,$path=(Get-Location)) {
    Get-ChildItem $path *.csproj -Recurse | ForEach-Object { $_.FullName } | Update-SpecificVersions -filter $id
    push-location $path
    Clear-ProjectDirectories 
    pop-location
}

function Get-NugetPackageAssembly {
    [CmdletBinding(DefaultParameterSetName="nupkgPath")]
    param (
        [parameter(Mandatory,ParameterSetName="nupkgPath")]
        [string]$NupkgPath,
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
            if ($flattenPath -eq $NupkgPath){
                throw "same paths"
            }
            New-Item $flattenPath -ItemType Directory -Force|Out-Null
            $packages=& Nuget List -Source "$NupkgPath"|ConvertTo-PackageObject
            Write-Verbose "Copy packages to $flattenPath and rename to zip"
            Get-ChildItem $NupkgPath *.nupkg |ForEach-Object{
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
            $packageAssemblies=$packages|ForEach-Object{
                $packageName=$_.Name
                $packageVersion=$_.Version
                Get-ChildItem "$flattenPath\$packageName.$packageVersion" "*.dll" -Recurse|ForEach-Object{
                    [PSCustomObject]@{
                        Package = $packageName
                        Version  = $packageVersion
                        Assembly = $_.Name
                        Framework = $_.Directory.Name
                    }
                }
            }|Sort-Object $_.Package
            if (!$keepFlatten){
                [Directory]::Delete($flattenPath,$true)|Out-Null        
            }
            $packageAssemblies
        }
        
    }
    
    end {
    }
}
function Install-SubModule{
    param(
        [string]$Name,
        [string[]]$Files,
        [string[]]$Packages
    )
    if (!(Get-Module $Name -ListAvailable)){
        Write-Host "Installing $Name"
        $installationPath="$($env:PSModulePath -split ";"|where-object{$_ -like "$env:USERPROFILE*"}|Select-Object -Unique)\$Name"
        New-Item $installationPath -ItemType Directory -Force
        New-Assembly -AssemblyName $Name -Files $Files -Packages $Packages -outputpath $installationPath
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

Install-NugetCommandLine