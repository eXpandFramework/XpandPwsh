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
                Write-Output "Installing $($Using:nuget.Name)..."
                & nuget Install $Using:nuget.Name -source "$($Using:psObj.Source);https://xpandnugetserver.azurewebsites.net/nuget" -OutputDirectory $Using:psObj.OutputDirectory -Version $Using:psObj.Version
                Invoke-Retry {
                    
                }
            } 
            $Workflow:complete = $Workflow:complete + 1 
            [int]$percentComplete = ($Workflow:complete * 100) / $Workflow:psObj.Nugets.Count
            Write-Progress -Id 1 -Activity "Installing Nugets" -PercentComplete $percentComplete -Status "$percentComplete% :$($nuget.Name)"
        }
        Write-Progress -Id 1 -Status "Ready" -Activity "Installing Nugets" -Completed
    }

    "Installing DX assemblies from $dxSources"
    $csv=(new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$dxVersion.csv")

    $resourcessDir="$PSScriptRoot\Reources"
    New-Item $resourcessDir -ItemType Directory -Force|out-null
    $csvPath="$resourcessDir\$dxVersion.csv"
    Set-content $csvPath $csv
    $nugets=Import-Csv $csvPath
    # $nugets = Get-DXNugets -path $sourcePath|Where-Object {$_.Name -notlike "DevExpress.DXCore.*"}
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

