
function Install-DevExpress {
    [alias("Install-DX")]
    param(
        [parameter(Mandatory)]
        [string]$binPath, 
        [parameter(Mandatory)]
        [string[]]$dxSources ,
        [parameter(Mandatory)]
        [string]$sourcePath ,
        [parameter(Mandatory)]
        [string]$dxVersion ,
        [string]$packagesFolder = "$binPath\TempDXNupkg",
        [int]$MaximumRetries=5
    )
    $ErrorActionPreference = "Stop"
    $hash=@{}
    $dxNugets=(Get-DxNugets $dxVersion)
    
    $dxNugets|ForEach-Object{
        $hash[$_.Assembly]=$_.Package
    }
    $projects=Get-ChildItem $sourcePath *.csproj -Recurse
    $nugets=$projects|Invoke-Parallel -ActivityName "Discovering packages" -VariablesToImport hash -Script {
        [xml]$csproj = Get-Content $_.FullName
        ($csproj.Project.ItemGroup.Reference.Include|Where-Object {$_ -like "DevExpress*" -and $_ -notlike "DevExpress.DXCore*" }|ForEach-Object {
            $assemblyName = [System.Text.RegularExpressions.Regex]::Match($_,"([^,]*)").Groups[1].Value
            $hash["$assemblyName.dll"]
        })
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
    $nuget=Get-NugetPath
    $psObj.Nugets|Invoke-Parallel -ActivityName "Installing DX" -VariablesToImport @("psObj","nuget") -script {
        $package=$_
        Write-Host "Installing $package $($psObj.Version) in $($psObj.OutputDirectory) from $($psObj.Source)" 
        Invoke-Retry -Maximum $MaximumRetries {
            & "$nuget"  Install "$package" -Source "$($psObj.Source)" -OutputDirectory "$($psObj.OutputDirectory)" -Version "$($psObj.Version)"
        }
    }
    
    Get-ChildItem -Path "$packagesFolder" -Include "*.dll" -Recurse  |Where-Object {
        $item = Get-Item $_
        $item.GetType().Name -eq "FileInfo" -and $item.DirectoryName -like "*net452"
    }|Copy-Item -Destination $binPath -Force 
}

