function Get-NugetPackages {
    param (
        [parameter(Mandatory)]
        [string]$filter,
        [parameter(Mandatory)]
        $nuget,
        [switch]$latest)

    
    $packages=& $nuget list $filter|foreach{Format-Nuget $_}|Group-Object Name|ForEach-Object{
        $_.Group|Sort-Object|Select-Object -First 1 -ExpandProperty Name
    }
    if ($latest){
        $packages|Sort-Object -Descending|ForEach-Object{
            $package=$_
            & $nuget list $_|foreach{Format-Nuget $_}|Group-Object Name|ForEach-Object{
                $version=$_.Group|Sort-Object -Descending|Select-Object -First 1 -ExpandProperty Version
                [PSCustomObject]@{
                    Name = $package
                    Version = $version
                }
            }
        }
    }
    else{
        $packages
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
