function Install-Xpand {
    param (
        [string]$Version,
        [Switch]$Latest,
        [validateSet("Assemblies", "Nuget", "Source", "VSIX")]
        [string[]]$Assets = @("Assemblies", "Nuget", "Source", "VSIX"),
        [string]$InstallationPath = "$([Environment]::GetFolderPath('MyDocuments'))\eXpandFramework",
        [switch]$SkipGac,
        [switch]$Quiet
    )
    $ErrorActionPreference="Stop"
    [Net.ServicePointManager]::Expect100Continue=$true
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $c=New-Object System.Net.WebClient
    $uri="https://raw.githubusercontent.com/eXpandFramework/XpandPwsh/master/XpandPwsh/Private/Xpand/InstallXpand.ps1"
    $scriptPath="$InstallationPath\InstallXpand.ps1"
    Write-Host "Downloading installation script from $uri into $scriptPath" -f Green
    New-Item $InstallationPath -ItemType Directory -Force -ErrorAction Continue
    if (Test-Path $scriptPath){
        Remove-Item $scriptPath
    }
    $c.DownloadFile($uri,$scriptPath)
    . $scriptPath
    $instalationParameters=@{
        Version=$Version
        Latest=$Latest
        Assets=$Assets
        InstallationPath=$InstallationPath
        SkipGac=$SkipGac
        Quiet=$Quiet
    }
    Write-Host "Installation parameters:" -f Yellow 
    $instalationParameters|Write-Output 
    InstallXpand @instalationParameters

}
