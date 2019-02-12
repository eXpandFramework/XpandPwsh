function Install-DX {
    param(
        [parameter(Mandatory)]
        [string]$binPath, 
        [parameter(Mandatory)]
        [string[]]$dxSources ,
        [parameter(Mandatory)]
        [string]$sourcePath ,
        [parameter(Mandatory)]
        [string]$dxVersion ,
        [string]$packagesFolder = "$binPath\TempDXNupkg"
    )
    $ErrorActionPreference = "Stop"
    "Installing DX assemblies from $dxSources"
    $allNugets=Get-DxNugets $dxVersion
    $nugets=Get-ChildItem $sourcePath *.csproj -Recurse|ForEach-Object{
        [xml]$csproj = Get-Content $_.FullName
        $csproj.Project.ItemGroup.Reference.Include|Where-Object {$_ -like "DevExpress*" -and $_ -notlike "DevExpress.DXCore*" }|ForEach-Object {
            $assemblyName = [System.Text.RegularExpressions.Regex]::Match($_,"([^,]*)").Groups[1].Value
            $item=$allNugets|Where-Object{$_.Assembly -eq $assemblyName}|Select-Object -First 1
            if (!$item){
                throw "project:$($_.FullName) assembly:$assemblyName"
            }
            $item.Package
        }
    }|Select-Object -Unique
    New-Item $packagesFolder -ItemType Directory -Force|out-null
    $psObj = [PSCustomObject]@{
        OutputDirectory = $(Get-Item $packagesFolder).FullName
        Source          = $dxSources -join ";"
        Nugets          = $nugets
        Version =$dxVersion
    }
    if ($nugets.Count -eq 0) {
        throw "No nugets found??"
    }

    $psObj.Nugets|Invoke-Parallel -ImportVariables {
        (& nuget Install $_ -source "$($psObj.Source)" -OutputDirectory "$($psObj.OutputDirectory)" -Version $psObj.Version)    
    }
    "Flattening nugets..." -f "Blue"
    Get-ChildItem -Path "$packagesFolder" -Include "*.dll" -Recurse  |Where-Object {
        $item = Get-Item $_
        $item.GetType().Name -eq "FileInfo" -and $item.DirectoryName -like "*net452"
    }|Copy-Item -Destination $binPath -Force 
}

