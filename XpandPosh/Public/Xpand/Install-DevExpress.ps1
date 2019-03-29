
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
    
    $installScript={
        param(
            $ActivityName
        )
        $nuget=Get-NugetPath
        $psObj.Nugets|Invoke-Parallel -ActivityName $ActivityName -VariablesToImport @("psObj","nuget") -script {
            $package=$_
            Write-Host "Installing $package $($psObj.Version) in $($psObj.OutputDirectory) from $($psObj.Source)" 
            & "$nuget"  Install "$package" -Source "$($psObj.Source)" -OutputDirectory "$($psObj.OutputDirectory)" -Version "$($psObj.Version)"
        }
    }
    $psObj.Nugets=$nugets|Where-Object{$_ -notmatch "win" -and $_ -notmatch "web" -and $_ -notmatch "expressapp" -and $_ -notmatch "baseimpl" }
    Write-Host "Agnostic non-XAF packages" -f Blue
    if ($psObj.Nugets){
        $psObj.Nugets|Write-Output
        & $installScript "Installing agnostic non-XAF DevExpress packages"
    }

    $psObj.Nugets=$nugets|Where-Object{($_ -match "win" -or $_ -match "web") -and $_ -notmatch "expressapp" }
    Write-Host "Non-agnostic-non-xaf packages" -f Blue
    if ($psObj.nugets){
        $psObj.Nugets|Write-Output
        & $installScript "Installing non-agnostic-non-XAF DevExpress packages"
    }
    
    $psObj.Nugets=$nugets|Where-Object{($_ -notmatch "win" -and $_ -notmatch "web") -and $_ -match "expressapp" }
    Write-Host "Agnostic-xaf packages" -f Blue
    if ($psObj.nugets){
        $psObj.Nugets|Write-Output
        & $installScript "Installing agnostic-XAF DevExpress packages"
    }
    
    $psObj.Nugets=$nugets|Where-Object{($_ -match "win" -or $_ -match "web") -and $_ -match "expressapp" }
    Write-Host "Non-agnostic-xaf packages" -f Blue
    if ($psObj.Nugets){
        $psObj.Nugets|Write-Output
        & $installScript "Installing non-agnostic-XAF DevExpress packages"
    }
    
    $psObj.Nugets=$nugets|Where-Object{$_ -match "baseimpl" }
    Write-Host "BaseImpl packages" -f Blue
    if ($psObj.nugets){
        $psObj.Nugets|Write-Output
        & $installScript "Installing baseimpl DevExpress packages"
    }
    
    Get-ChildItem -Path "$packagesFolder" -Include "*.dll" -Recurse  |Where-Object {
        $item = Get-Item $_
        $item.GetType().Name -eq "FileInfo" -and $item.DirectoryName -like "*net452"
    }|Copy-Item -Destination $binPath -Force 
}
