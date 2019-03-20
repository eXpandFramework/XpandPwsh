function Install-Xpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "$([Environment]::GetFolderPath('MyDocuments'))\eXpandFramework",
        [switch]$SkipGac
    )
throw "Not functional see #349"    
    [Net.ServicePointManager]::Expect100Continue=$true
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $client=New-Object System.Net.WebClient
    
    if (!(Get-Module 7Zip4Powershell -ListAvailable)){
        Install-Module 7Zip4Powershell -Scope CurrentUser -Force
    }
    if (!(Test-Path "$InstallationPath\UnInstall-Xpand.ps1")) {
        if (!(Test-Path $InstallationPath)){
            Write-Host "Creating $InstallationPath" -f Green
            New-Item $InstallationPath -ItemType Directory|Out-Null
        }
    }
    else {
        Write-Host ""$InstallationPath\UnInstall-Xpand.ps1" exists, unistalling." -f "Red"
        Read-Host "Press a key to uninstall."
        . "$InstallationPath\UnInstall-Xpand.ps1"
        UnInstall-Xpand $InstallationPath    
    }
    Write-Host "Installing $($Assets -join ', ') into $InstallationPath."-f Green
    Write-Host "Additional parameters: Version, Latest, Assets, InstallationPath" -f Yellow

    $nuget="$InstallationPath\nuget.exe"
    $client.DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe",$nuget)
    
    $repo = "eXpand"
    $release=$Version

    if ($Latest) {
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
    elseif (!$Version) {
        Write-Host "Finding latest Xpand version" -f Green
        
        $release = ((& $nuget list eXpandlib -source "https://api.nuget.org/v3/index.json").Split(" ")[1])
        $release+=".0"
        Write-Host "Latest official:$release" -f Green
    }
    if ($Assets -contains "Source") {
        Write-Host "Downloading Sources from $repo repository into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-Source-$release.zip"
        $zip = "Xpand-Source-$release.zip"
        $client.DownloadFile($uri,"$InstallationPath\$zip")
        Start-Process powershell "-Command Expand-7Zip '$InstallationPath\$zip' '$InstallationPath\Sources'" -WorkingDirectory $InstallationPath
    }
    if ($Assets -contains "Nuget") {
        Write-Host "Downloading Nugets from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Nupkg-$release.zip"
        $zip = "$InstallationPath\Nupkg-$release.zip"
        $client.DownloadFile($uri,$zip)
        $nugetPath = "$InstallationPath\Packages"
        Remove-Item $nugetPath -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $nugetPath" -f Green
        Start-Process powershell "-Command Expand-7Zip '$zip' '$nugetPath'" -WorkingDirectory $InstallationPath
    }
    if ($Assets -contains "Assemblies") {
        Write-Host "Downloading assemblies from $repo repo into $InstallationPath" -f Green
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-lib-$release.zip"
        $zip = "$InstallationPath\Xpand-lib-$release.zip"
        $client.DownloadFile($uri,$zip)
        $xpandDLL = "$InstallationPath\Xpand.DLL"
        Remove-Item $xpandDLL -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $xpandDLL" -f Green
        Expand-7Zip $zip $xpandDLL 
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

            $count=(Get-ChildItem "$InstallationPath\Xpand.DLL" *.dll).Count
            Write-Progress -Activity gacInstaller -Status "Installing assemblies in GAC"
            $i=0
            & "$InstallationPath\Xpand.Dll\GAcInstaller.exe" -m Install|ForEach-Object{
                if ($_){
                    $i++;
                    Write-Progress -Activity gacInstaller -Status $_ -PercentComplete $($i*100/$count)
                }
                $_
            }
            Write-Progress -Activity gacInstaller -Status "Finish GAC installtion" -Completed
        }
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
    Write-Host "Creating Uninstall-Xpand.ps1" -f Green
    $client.DownloadFile("https://raw.githubusercontent.com/eXpandFramework/XpandPosh/master/XpandPosh/Public/UnInstall-Xpand.ps1","$InstallationPath\UnInstall-Xpand.ps1")
    Add-Content "$InstallationPath\UnInstall-Xpand.ps1" "`nUnInstall-Xpand" 
    Write-Host "Finished installtion in $InstallationPath" -f Green
}

