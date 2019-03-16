function Install-Xpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "${env:ProgramFiles(x86)}\eXpandFramework",
        [switch]$SkipGac
    )

    if (!(Test-Path "$InstallationPath\UnInstall-Xpand.ps1")) {
        if (!(Test-Path $InstallationPath)){
            Write-Host "Creating $InstallationPath" -f Blue
            New-Item $InstallationPath -ItemType Directory|Out-Null
        }
    }
    else {
        Write-Host ""$InstallationPath\UnInstall-Xpand.ps1" exists, unistalling." -f "Red"
        Read-Host "Press a key to continue."
        . "$PSSCriptRoot\UnInstall-Xpand.ps1"
        UnInstall-Xpand $InstallationPath    
    }
    Write-Host "Installing $($Assets -join ', ') into $InstallationPath."-f Blue
    Write-Host "Additional paraters are available Version, Latest, Assets, InstallationPath" -f Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $repo = "eXpand"
    $release=$Version
    if (!$Latest) {
        Write-Host "Finding latest Xpand version" -f Blue
        $release = (Invoke-WebRequest -Uri "https://api.github.com/repos/eXpandFramework/eXpand/releases" -UseBasicParsing | ConvertFrom-Json)[0].tag_name
        Write-Host "Latest official:$release" -f Blue
        $lab = (Invoke-WebRequest -Uri "https://api.github.com/repos/eXpandFramework/lab/releases" -UseBasicParsing | ConvertFrom-Json)[0].tag_name
        Write-Host "Latest lab:$lab" -f Blue
        if ($lab -gt $release) {
            $repo = "lab"
            $release = $lab
        }
    }
    if ($Assets -contains "Assemblies") {
        Write-Host "Downloading assemblies from $repo repo into $InstallationPath" -f Blue
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-lib-$release.zip"
        $zip = "$InstallationPath\Xpand-lib-$release.zip"
        Invoke-WebRequest $uri -Out $zip
        $xpandDLL = "$InstallationPath\Xpand.DLL"
        Remove-Item $xpandDLL -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $xpandDLL" -f Blue
        Expand-Archive $zip -DestinationPath $xpandDLL
        Remove-Item $zip
        $demos = "$InstallationPath\Demos"
        Write-Host "Moving Demos" -f Blue
        Remove-Item $demos -Recurse -Force -ErrorAction SilentlyContinue
        New-Item $demos -ItemType Directory -Force|Out-Null
        New-Item "$demos\Testers" -ItemType Directory -Force|Out-Null
        Get-ChildItem $xpandDLL *Tester.*|Move-Item -Destination "$demos\Testers" 
        "FeatureCenter", "SecurityDemo", "SecuritySytemExample", "XpandTestExecutor", "XVideoRental", "ExternalApplication", "ConsoleApplicationServer"|ForEach-Object {
            New-Item "$demos\Demos\$_" -ItemType Directory -Force|Out-Null
            Get-ChildItem $xpandDLL "*$_*"|Move-Item -Destination "$demos\Demos\$_" 
        }
        Write-Host "Write Registry " -f Blue
        $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders", $true)
        $subKey.CreateSubKey("Xpand").SetValue("", $xpandDLL)
        if (!$SkipGac) {
            Write-Host "$Installing to GAC" -f Blue
            Set-Location "$InstallationPath\Xpand.DLL"
            & .\gacInstaller.exe -m Install
        }
    }
    if ($Assets -contains "Nuget") {
        Write-Host "Downloading Nugets from $repo repo into $InstallationPath" -f Blue
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Nupkg-$release.zip"
        $zip = "$InstallationPath\Nupkg-$release.zip"
        Invoke-WebRequest $uri -Out $zip
        $nugetPath = "$InstallationPath\Packages"
        Remove-Item $nugetPath -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $nugetPath" -f Blue
        Expand-Archive $zip -DestinationPath $nugetPath 
        Remove-Item $zip
    }
    if ($Assets -contains "Source") {
        Write-Host "Downloading Sources from $repo repo into $InstallationPath" -f Blue
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-Source-$release.zip"
        $zip = "$InstallationPath\Xpand-Source-$release.zip"
        Invoke-WebRequest $uri -Out $zip
        $sourcesPath = "$InstallationPath\Sources"
        Remove-Item $sourcesPath -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $sourcesPath" -f Blue
        Expand-Archive $zip -DestinationPath $sourcesPath
        Remove-Item $zip
    }
    if ($Assets -contains "VSIX") {
        Write-Host "Downloading VSIX from $repo repo into $InstallationPath" -f Blue
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand.VSIX-$release.vsix"
        $vsix = "$InstallationPath\Xpand.VSIX-$release.vsix"
        Invoke-WebRequest $uri -Out $vsix
        Write-Host "Download VSIX bootstrapper" -f Blue
        Invoke-WebRequest "https://github.com/Microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe" -OutFile "$env:TEMP\VSIXBootstrapper.exe"
        write-host "Installing VSIX" -f Blue
        & "$env:TEMP\VSIXBootstrapper.exe" $vsix
    }
    Invoke-WebRequest "https://raw.githubusercontent.com/eXpandFramework/XpandPosh/master/XpandPosh/Public/UnInstall-Xpand.ps1" -OutFile "$InstallationPath\UnInstall-Xpand.ps1"
}
