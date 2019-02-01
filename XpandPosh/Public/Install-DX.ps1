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
    workflow Install-AllDXNugets {
        param($psObj)
        $complete = 0
        Foreach -parallel ($nuget in $psObj.Nugets) { 
            InlineScript {
                Write-Output "Installing $($Using:nuget)..."
                Invoke-Retry {
                    & nuget Install $Using:nuget -source "$($Using:psObj.Source);https://xpandnugetserver.azurewebsites.net/nuget" -OutputDirectory $Using:psObj.OutputDirectory -Version $Using:psObj.Version    
                }
            } 
            $Workflow:complete = $Workflow:complete + 1 
            [int]$percentComplete = ($Workflow:complete * 100) / $Workflow:psObj.Nugets.Count
            Write-Progress -Id 1 -Activity "Installing DX Nugets" -PercentComplete $percentComplete -Status "$percentComplete% :$($nuget.Package)"
        }
        Write-Progress -Id 1 -Status "Ready" -Activity "Installing DX Nugets" -Completed
    }

    "Installing DX assemblies from $dxSources"
    $allNugets=Get-XDxNugets $dxVersion
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

    Install-AllDXNugets -psObj $psObj
    "Flattening nugets..." -f "Blue"
    Get-ChildItem -Path "$packagesFolder" -Include "*.dll" -Recurse  |Where-Object {
        $item = Get-Item $_
        $item.GetType().Name -eq "FileInfo" -and $item.DirectoryName -like "*net452"
    }|Copy-Item -Destination $binPath -Force 
}

