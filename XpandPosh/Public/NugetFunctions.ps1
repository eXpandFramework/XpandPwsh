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
        try{
            Get-NugetPackageSearchMetadata -Name "a" -Sources $PSScriptRoot -ErrorAction SilentlyContinue|out-null
        }
        catch{

        }
    }
    
    process {
        $packages=& Nuget List -source $NupkgPath|convertto-packageobject
        Write-Verbose "Packages found:`r`n$packages"
        
        $published=$packages|Select-Object -ExpandProperty Name| Invoke-Parallel -activityName "Getting latest versions from sources" -VariablesToImport @("source") -Script  { 
            Write-Verbose "Get $_ metadata from $Source"
            (Get-NugetPackageSearchMetadata -Name $_ -Sources $Source|Select-object -ExpandProperty Metadata|Get-MetadataVersion)
        } 
        Write-Verbose "Published packages:`r`n$published"
        $needPush=$packages|Where-Object{
            $p=$_
            $published |Where-Object{
                $_.Name -eq $p.Name -and $_.Version -eq $_.Version
            }
        }
        $needPush|Invoke-Parallel -ActivityName "Publishing Nugets" -VariablesToImport @("apikey","NupkgPath","Source") -Script -IgnoreLastEditCode {
            $package="$NupkgPath\$($_.Name).$($_.Version).nupkg"
            Write-Host "Pushing $package in $Source "
            nuget Push "$package" $ApiKey -source $Source
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



function Remove-ProjectNuget{
    param(
        [parameter(Mandatory)]
        [string]$id,
        [string]$path=(Get-Location)
    )
    Get-ChildItem $path *.csproj -Recurse | ForEach-Object { 
        $fiLeName=$_.FullName 
        [xml]$project=Get-Content $_.FullName 
        $project.Project.ItemGroup.Reference|Where-Object{$_.Include -like "*$id*"}|ForEach-Object{
            if ($_.SpecificVersion){
                $_.SpecificVersion="False"
            }
            if($_.HintPath){
                $_.ChildNodes|ForEach-Object{
                    $_.ParentNode.RemoveChild($_)
                }
            }
        }
        $project.Save($fiLeName)
    } 
    push-location $path
    Clear-ProjectDirectories 
    pop-location
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