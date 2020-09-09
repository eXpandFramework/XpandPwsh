function InstallXpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "$([Environment]::GetFolderPath('MyDocuments'))\eXpandFramework",
        [switch]$SkipGac,
        [switch]$Quiet
    )
    $ErrorActionPreference = "Stop"
    [Net.ServicePointManager]::Expect100Continue = $true
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $client = New-Object System.Net.WebClient
    if ($Assets -contains "Assemblies"){
        $isElevated=[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
        if (!$isElevated){
            throw "The script needs administrator rights. Right click on the powershell icon and choose run as Administrator"
        }
    }
    if (!(Get-Module 7Zip4Powershell -ListAvailable)) {
        Install-Module 7Zip4Powershell -Scope CurrentUser -Force
    }
    if ((Test-Path "$InstallationPath\UnInstall-Xpand.ps1")) {
        Write-Host ""$InstallationPath\UnInstall-Xpand.ps1" exists, unistalling." -f "Red"
        Read-Host "Press a key to uninstall."
        . "$InstallationPath\UnInstall-Xpand.ps1"
    }
    if (!(Test-Path $InstallationPath)) {
        Write-Host "Creating $InstallationPath" -f Green
        New-Item $InstallationPath -ItemType Directory|Out-Null
    }
    Write-Host "Installing $($Assets -join ', ') into $InstallationPath."-f Green
    Write-Host "Additional parameters: Version, Latest, Assets, InstallationPath" -f Yellow
    
    $repo = "eXpand"
    $release = $Version

    if ($Latest) {
        Write-Host "Finding latest Xpand version" -f Green
        $release = (Invoke-RestMethod "https://azuresearch-usnc.nuget.org/query?q=eXpandLib&take=1").data.version
        Write-Host "Latest official:$release" -f Yellow
        $lab = ((Invoke-RestMethod "https://xpandnugetstats.azurewebsites.net/api/totals/packages?packagesource=xpand")|where-object{$_.id -eq "expandlib"}).version
        Write-Host "Latest lab:$lab" -f Green
        if ($lab -gt $release) {
            $repo = "eXpand.lab"
            $release = $lab
        }
    }
    elseif (!$Version) {
        Write-Host "Finding latest Xpand version" -f Green
        $release=(Invoke-RestMethod "https://azuresearch-usnc.nuget.org/query?q=eXpandLib&take=1").data.version
        $release+=".0"
        Write-Host "Latest official:$release" -f Green
    }
    elseif($Version){
        $systemVersion=New-Object System.Version($Version)
        if ($systemVersion.Revision -gt 0){
            $repo="eXpand.lab"
        }
        if ($systemVersion.Revision -eq -1){
            $Version+=".0"
        }
        $release=$Version
        Write-Host "$Version is a $repo version" -f Green
    }
    if (([version]$Version) -gt "20.1.602.4"){
        throw "The Nuget.org is the only ditribution channel starting from v20.1.602.4"
    }
    if ($release.Revision -eq -1){
        $release=New-Object System.Version("$release.0")
    }
    if ($Assets -contains "Source") {
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-Source-$release.zip"
        Write-Host "Downloading Sources from $uri into $InstallationPath" -f Green
        $zip = "Xpand-Source-$release.zip"
        $client.DownloadFile($uri, "$InstallationPath\$zip")
        Start-Process powershell "-Command Expand-7Zip '$InstallationPath\$zip' '$InstallationPath\Sources'" -WorkingDirectory $InstallationPath
    }
    if ($Assets -contains "Nuget") {
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Nupkg-$release.zip"
        Write-Host "Downloading Nugets from $uri into $InstallationPath" -f Green
        $zip = "$InstallationPath\Nupkg-$release.zip"
        $client.DownloadFile($uri, $zip)
        $nugetPath = "$InstallationPath\Packages"
        Remove-Item $nugetPath -Recurse -Force -ErrorAction SilentlyContinue
        write-host "Expanding files into $nugetPath" -f Green
        Start-Process powershell "-Command Expand-7Zip '$zip' '$nugetPath'" -WorkingDirectory $InstallationPath
    }
    if ($Assets -contains "Assemblies") {
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand-lib-$release.zip"
        Write-Host "Downloading assemblies from $uri into $InstallationPath" -f Green
        $zip = "$InstallationPath\Xpand-lib-$release.zip"
        $client.DownloadFile($uri, $zip)
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
        $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework", $true)
        $subKey.CreateSubKey("AssemblyFolders").CreateSubKey("Xpand").SetValue("", $xpandDLL)
        if (!$SkipGac) {
            Write-Host "$Installing to GAC" -f Green
            Set-Location "$InstallationPath\Xpand.DLL"
            $count = (Get-ChildItem "$InstallationPath\Xpand.DLL" *.dll).Count
            Write-Progress -Activity gacInstaller -Status "Installing assemblies in GAC"
            $i = 0
            & "$InstallationPath\Xpand.Dll\GAcInstaller.exe" -m Install|ForEach-Object {
                if ($_) {
                    $i++;
                    Invoke-Command  {
                        $ErrorActionPreference="SilentlyContinue"
                        Write-Progress -Activity gacInstaller -Status $_ -PercentComplete $($i * 100 / $count)
                    } 
                }
                $_
            }
            Write-Progress -Activity gacInstaller -Status "Finish GAC installtion" -Completed
        }
    }
    if ($Assets -contains "VSIX") {
        $uri = "https://github.com/eXpandFramework/$repo/releases/download/$release/Xpand.VSIX-$release.vsix"
        Write-Host "Downloading VSIX from $uri into $InstallationPath" -f Green
        $vsix = "$InstallationPath\Xpand.VSIX-$release.vsix"
        $client.DownloadFile($uri, $vsix)
        Write-Host "Download VSIX bootstrapper" -f Green
        $client.DownloadFile("https://github.com/Microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe", "$InstallationPath\VSIXBootstrapper.exe")
        write-host "Installing VSIX" -f Green
        $sp=@{
            FilePath="`"$InstallationPath\VSIXBootstrapper.exe`""
            ArgumentList="`"$vsix`""
            WorkingDirectory="."
            Wait=$Quiet
        }
        if ($Quiet){
            $sp.ArgumentList= @("/q",$vsix)
        }
        Start-Process @sp
    }
    Write-Host "Creating Uninstall-Xpand.ps1" -f Green
    $client.DownloadFile("https://raw.githubusercontent.com/eXpandFramework/XpandPwsh/master/XpandPwsh/Public/Xpand/UnInstall-Xpand.ps1", "$InstallationPath\UnInstall-Xpand.ps1")
    $unistallCall="`r`nUnInstall-Xpand"
    if ($Quiet){
        $unistallCall+=" -Quiet"
    }
    Add-Content "$InstallationPath\UnInstall-Xpand.ps1" $unistallCall 
    Write-Host "Finished installtion in $InstallationPath" -f Green
}



