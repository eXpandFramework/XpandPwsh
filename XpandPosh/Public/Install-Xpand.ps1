function Install-Xpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "$env:ProgramData\eXpandFramework",
        [switch]$SkipGac
    )

    if (!(Test-Path $InstallationPath)) {
        Write-Host "Creating $InstallationPath" 
        New-Item $InstallationPath -ItemType Directory|Out-Null
    }
    else {
        Write-Host "$InstallationPath exists, unistalling." -f "Red"
        Read-Host "Press a key to continue."
        . "$PSSCriptRoot\UnInstall-Xpand.ps1"
        UnInstall-Xpand $InstallationPath    
    }
    Write-Host "Installing $($Assets -join ', ') into $InstallationPath."
    Write-Host "Additional paraters are available Version, Latest, Assets, InstallationPath"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $repo = "eXpand"
    if (!$Version) {
        Write-Host "Finding latest Xpand version"
        $release = (Invoke-WebRequest -Uri "https://api.github.com/repos/eXpandFramework/eXpand/releases" -UseBasicParsing | ConvertFrom-Json)[0].tag_name
        Write-Host "Latest official:$release"
        if ($Latest) {
            $lab = (Invoke-WebRequest -Uri "https://api.github.com/repos/eXpandFramework/lab/releases" -UseBasicParsing | ConvertFrom-Json)[0].tag_name
            Write-Host "Latest lab:$lab"
            if ($lab -gt $release) {
                $repo = "lab"
                $release = $lab
            }
        }
        if ($Assets -contains "Assemblies") {
            Write-Host "Downloading assemblies from $repo repo into $InstallationPath"
            $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-lib-$release.zip"
            $zip = "$InstallationPath\Xpand-lib-$release.zip"
            Invoke-WebRequest $uri -Out $zip
            $xpandDLL = "$InstallationPath\Xpand.DLL"
            Remove-Item $xpandDLL -Recurse -Force -ErrorAction SilentlyContinue
            write-host "Expanding files into $xpandDLL"
            Expand-Archive $zip -DestinationPath $xpandDLL
            Remove-Item $zip
            $demos = "$InstallationPath\Demos"
            Write-Host "Moving Demos"
            Remove-Item $demos -Recurse -Force -ErrorAction SilentlyContinue
            New-Item $demos -ItemType Directory -Force|Out-Null
            New-Item "$demos\Testers" -ItemType Directory -Force|Out-Null
            Get-ChildItem $xpandDLL *Tester.*|Move-Item -Destination "$demos\Testers" 
            "FeatureCenter", "SecurityDemo", "SecuritySytemExample", "XpandTestExecutor", "XVideoRental", "ExternalApplication", "ConsoleApplicationServer"|ForEach-Object {
                New-Item "$demos\Demos\$_" -ItemType Directory -Force|Out-Null
                Get-ChildItem $xpandDLL "*$_*"|Move-Item -Destination "$demos\Demos\$_" 
            }
            Write-Host "Write Registry "
            $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
            $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders", $true)
            $subKey.CreateSubKey("Xpand").SetValue("", $xpandDLL)
            if (!$SkipGac) {
                Write-Host "$Installing to GAC"
                Set-Location "$InstallationPath\Xpand.DLL"
                & .\gacInstaller.exe -m Install
            }
        }
        if ($Assets -contains "Nuget") {
            Write-Host "Downloading Nugets from $repo repo into $InstallationPath"
            $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Nupkg-$release.zip"
            $zip = "$InstallationPath\Nupkg-$release.zip"
            Invoke-WebRequest $uri -Out $zip
            $nugetPath = "$InstallationPath\Packages"
            Remove-Item $nugetPath -Recurse -Force -ErrorAction SilentlyContinue
            write-host "Expanding files into $nugetPath"
            Expand-Archive $zip -DestinationPath $nugetPath 
            Remove-Item $zip
        }
        if ($Assets -contains "Source") {
            Write-Host "Downloading Sources from $repo repo into $InstallationPath"
            $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-Source-$release.zip"
            $zip = "$InstallationPath\Xpand-Source-$release.zip"
            Invoke-WebRequest $uri -Out $zip
            $sourcesPath = "$InstallationPath\Sources"
            Remove-Item $sourcesPath -Recurse -Force -ErrorAction SilentlyContinue
            write-host "Expanding files into $sourcesPath"
            Expand-Archive $zip -DestinationPath $sourcesPath
            Remove-Item $zip
        }
        if ($Assets -contains "VSIX") {
            Write-Host "Downloading VSIX from $repo repo into $InstallationPath"
            $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand.VSIX-$release.vsix"
            $vsix = "$InstallationPath\Xpand.VSIX-$release.vsix"
            Invoke-WebRequest $uri -Out $vsix
            Write-Host "Download VSIX bootstrapper"
            Invoke-WebRequest "https://github.com/Microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe" -OutFile "$Installationpath\VSIXBootstrapper.exe"
            write-host "Installing VSIX"
            & "$InstallationPath\VSIXBootstrapper.exe" $vsix
        }
    }
}

