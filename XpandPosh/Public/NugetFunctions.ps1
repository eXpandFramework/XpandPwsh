using namespace System
using namespace System.Reflection
using namespace System.Text.RegularExpressions
using namespace System.IO
function Get-DxNugets{
    param(
        [parameter(Mandatory)]
        [string]$version
    )
    (new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv")|ConvertFrom-csv
}
function Update-NugetPackages{
    param(
        [string]$sourcePath,
        [string]$filter,
        [string]$repositoryPath
    )
    $sources=Get-PackageSourceLocations
    $packages=Get-NugetPackages -filter $filter -latest -sources $sources
    Get-ChildItem $sourcePath *.csproj -Recurse|ForEach-Object {
        [xml]$xml = Get-Content $_.FullName
        $packageConfigPath = "$($_.DirectoryName)\packages.config"
        if (Test-path $packageConfigPath) {
            [xml]$packageConfig = Get-Content $packageConfigPath
            if ($packageConfig.packages) {
                $xml.Project.ItemGroup.Reference|Where-Object {$_.Include -like $filter}|ForEach-Object {
                    $reference=$_.Include
                    $configPackage=$packageConfig.packages.package|Where-Object{$_.id -eq $reference}
                    $package=$packages |Where-Object {$_.Name -eq $reference}
                    if ($package.Version -ne $configPackage.version){
                        & Nuget Update $packageConfigPath -id $package.Name -source $sources -RepositoryPath $repositoryPath -safe -Version $package.Version
                    }
                }
            }
        }
    }
}
function Get-PackageSourceLocations{
    $(Get-PackageSource|Select-Object -ExpandProperty Location -Unique) -join ";"
}
function Get-NugetPackages {
    param (
        [parameter(Mandatory)]
        [string]$filter,
        [string]$sources,
        [switch]$latest)

    Install-NugetCommandLine|Out-null
    $packageSource=$sources
    if (!$packageSource){
        $packageSource=Get-PackageSourceLocations
    }
    $packages=nuget list $filter -source $packageSource |ForEach-Object{Format-Nuget $_}|Group-Object Name|ForEach-Object{
        $_.Group|Sort-Object|Select-Object -First 1 -ExpandProperty Name
    }|Where-Object{$_ -like $filter}
    $packages|Sort-Object -Descending|ForEach-Object{
        $package=$_
        Write-Host "Listing all version for $_ "
        $allVersions=& nuget list $_ -source $packageSource -AllVersion|ForEach-Object{Format-Nuget $_}
        if ($latest){
            $allVersions|Group-Object Name|ForEach-Object{
                $version=$_.Group|Sort-Object -Descending|Select-Object -First 1 -ExpandProperty Version
                [PSCustomObject]@{
                    Name = $package
                    Version = $version
                }
            }
        }
        else{
            $allVersions
        }   
    }
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

function New-Assembly {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $AssemblyName,
        [parameter(Mandatory)]
        $Code,
        [parameter()]
        $Packages=@(),
        [parameter()]
        $path="$PSScriptRoot\$assemblyName"
    )
    
    begin {
    }
    
    process {
        push-location $env:TEMP
        & {
            if (Test-Path "$env:TEMP\$assemblyName"){
                get-childitem "$env:TEMP\$assemblyName" -Recurse|Remove-Item -ErrorAction Continue -Force -Recurse
            }
            dotnet new classlib --name $assemblyName --force
            Push-Location $AssemblyName
            $packages |ForEach-Object{
                dotnet add package $_
            }
            Remove-Item ".\Class1.cs"
            $code|Out-file ".\$assemblyName.cs" -encoding UTF8
            dotnet publish
            new-item $path -ItemType Directory -Force
            get-childitem ".\bin\Debug\netstandard2.0\publish"|ForEach-Object{
                Copy-Item $_.FullName -Destination $path -force
            }
            Pop-Location
            Pop-Location
        }|Write-Verbose
        "$path\$AssemblyName.dll"
    }
    
    end {
    }
}
function Install-NugetSearch{
    if (!(Get-Module NugetSearch -ListAvailable)){
        $code=Get-Content "$PSScriptRoot\NugetSearch.cs" -Raw
        $assembly=New-Assembly -AssemblyName NugetSearch -Code $code -Packages @("NuGet.Protocol.Core.v3","PowerShellStandard.Library") -path "$env:TEMP\$([Guid]::NewGuid())"
        $installationPath="$($env:PSModulePath -split ";"|where-object{$_ -like "$env:USERPROFILE*"}|Select-Object -Unique)\NugetSearch"
        New-Item $installationPath -ItemType Directory -Force
        Get-ChildItem (get-item $assembly).DirectoryName -Recurse|ForEach-Object{
            Copy-Item $_.FullName $installationPath
        }
    }
}
function Get-NugetPackageVersions {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $packageName
    )
    
    begin {
        Install-NugetSearch
    }
    
    process {
        Get-NugetPackageSearchMetadata -Name $packageName|ForEach-Object{
            $_.Version.ToString()
        }
    }
    
    end {
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