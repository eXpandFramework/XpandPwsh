function Install-Xpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "${env:ProgramFiles(x86)}\eXpandFramework",
        [switch]$SkipGac
    )
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $client=New-Object System.Net.WebClient
    if (!(Test-Path "$InstallationPath\UnInstall-Xpand.ps1")) {
        if (!(Test-Path $InstallationPath)){
            Write-Host "Creating $InstallationPath" -f Green
            New-Item $InstallationPath -ItemType Directory|Out-Null
        }
    }
    else {
        Write-Host ""$InstallationPath\UnInstall-Xpand.ps1" exists, unistalling." -f "Red"
        Read-Host "Press a key to continue."
        . "$InstallationPath\UnInstall-Xpand.ps1"
        UnInstall-Xpand $InstallationPath    
    }
    Write-Host "Installing $($Assets -join ', ') into $InstallationPath."-f Green
    Write-Host "Additional paraters are available Version, Latest, Assets, InstallationPath" -f Yellow

    $nuget="$InstallationPath\nuget.exe"
    $client.DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe",$nuget)
    
    $repo = "eXpand"
    $release=$Version
    if (!$Latest) {
        Write-Host "Finding latest Xpand version" -f Green
        $release = (& $nuget list eXpandlib -source "https://api.nuget.org/v3/index.json").Split(" ")[1]
        Write-Host "Latest official:$release" -f Green
        $lab = (& $nuget list eXpandlib -source "https://xpandnugetserver.azurewebsites.net/nuget").Split(" ")[1]
        Write-Host "Latest lab:$lab" -f Green
        if ($lab -gt $release) {
            $repo = "lab"
            $release = $lab
        }
    }
    if ($Assets -contains "Assemblies") {
        Write-Host "Downloading assemblies from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-lib-$release.zip"
        $zip = "$InstallationPath\Xpand-lib-$release.zip"
        $client.DownloadFile($uri,$zip)
        $xpandDLL = "$InstallationPath\Xpand.DLL"
        Remove-Item $xpandDLL -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $xpandDLL" -f Green
        Expand-Archive "$zip" -DestinationPath $xpandDLL -Force
        Remove-Item $zip
        $demos = "$InstallationPath\Demos"
        Write-Host "Moving Demos" -f Green
        Remove-Item $demos -Recurse -Force -ErrorAction SilentlyContinue
        New-Item $demos -ItemType Directory -Force|Out-Null
        New-Item "$demos\Testers" -ItemType Directory -Force|Out-Null
        Get-ChildItem $xpandDLL *Tester.*|Move-Item -Destination "$demos\Testers" 
        "FeatureCenter", "SecurityDemo", "SecuritySytemExample", "XpandTestExecutor", "XVideoRental", "ExternalApplication", "ConsoleApplicationServer"|ForEach-Object {
            New-Item "$demos\Demos\$_" -ItemType Directory -Force|Out-Null
            Get-ChildItem $xpandDLL "*$_*"|Move-Item -Destination "$demos\Demos\$_" 
        }
        Write-Host "Write Registry " -f Green
        $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders", $true)
        $subKey.CreateSubKey("Xpand").SetValue("", $xpandDLL)
        if (!$SkipGac) {
            Write-Host "$Installing to GAC" -f Green
            Set-Location "$InstallationPath\Xpand.DLL"
            & .\gacInstaller.exe -m Install
        }
    }
    Set-Location $InstallationPath
    if ($Assets -contains "Nuget") {
        Write-Host "Downloading Nugets from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Nupkg-$release.zip"
        $zip = "$InstallationPath\Nupkg-$release.zip"
        $client.DownloadFile($uri,$zip)
        $nugetPath = "$InstallationPath\Packages"
        Remove-Item $nugetPath -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $nugetPath" -f Green
        Expand-Archive $zip -DestinationPath $nugetPath 
        Remove-Item $zip
    }
    if ($Assets -contains "Source") {
        Write-Host "Downloading Sources from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-Source-$release.zip"
        $zip = "$InstallationPath\Xpand-Source-$release.zip"
        $client.DownloadFile($uri,$zip)
    }
    if ($Assets -contains "VSIX") {
        Write-Host "Downloading VSIX from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand.VSIX-$release.vsix"
        $vsix = "$InstallationPath\Xpand.VSIX-$release.vsix"
        $client.DownloadFile($uri,$vsix)
        Write-Host "Download VSIX bootstrapper" -f Green
        $client.DownloadFile("https://github.com/Microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe","$env:TEMP\VSIXBootstrapper.exe")
        write-host "Installing VSIX" -f Green
        & "$env:TEMP\VSIXBootstrapper.exe" $vsix
    }
    $client.DownloadFile("https://raw.githubusercontent.com/eXpandFramework/XpandPosh/master/XpandPosh/Public/UnInstall-Xpand.ps1","$InstallationPath\UnInstall-Xpand.ps1")
    Add-Content "$InstallationPath\UnInstall-Xpand.ps1" "`nUnInstall-Xpand" 
}

 