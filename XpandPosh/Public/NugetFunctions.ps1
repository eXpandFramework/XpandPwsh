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
                    $package=$packages |where {$_.Name -eq $reference}
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

    Install-NugetCommandLine
    $packageSource=$sources
    if (!$packageSource){
        $packageSource=Get-PackageSourceLocations
    }
    $packages=nuget list $filter -source $packageSource |foreach{Format-Nuget $_}|Group-Object Name|ForEach-Object{
        $_.Group|Sort-Object|Select-Object -First 1 -ExpandProperty Name
    }
    $packages|Sort-Object -Descending|ForEach-Object{
        $package=$_
        $allVersions=& nuget list $_ -source $packageSource|foreach{Format-Nuget $_}
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

function Remove-Nuget($id) {
    Get-ChildItem -Recurse -Filter '*.csproj' | ForEach-Object { $_.FullName } | False-XpandSpecificVersions
    CleanProjectCore
    Get-ChildItem -Recurse -Filter 'packages.config' | ForEach-Object { $_.FullName } | Write-XmlComment -xPath "//package[contains(@id,'$id')]"

    Get-ChildItem -Recurse | Where-Object { $_.PSIsContainer } | Where-Object { $_.Name -eq 'packages' } | ForEach-Object {
  		    Push-Location $_
  		    Get-ChildItem -Recurse | Where-Object { $_.PSIsContainer } |  Where-Object { $_.Name -like "$id*" } | Remove-Item -Recurse
    }        
}

function Install-NugetCommandLine{
    Install-Chocolatey
    cinst NuGet.CommandLine
}
