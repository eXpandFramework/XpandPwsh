function UnInstall-Xpand {
    [CmdletBinding()]
    param (
        [string]$InstallationPath,
        [switch]$Quiet
    )
    
    begin {
    }
    
    process {
        $ErrorActionPreference="Stop"
        [Net.ServicePointManager]::Expect100Continue=$true
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $c=New-Object System.Net.WebClient
        $uri="https://raw.githubusercontent.com/eXpandFramework/XpandPosh/master/XpandPosh/Private/Xpand/UnInstallXpand.ps1"
        $scriptPath="$PSScriptRoot\UnInstallXpand.ps1"
        Write-Host "Downloading installation script from $uri into $scriptPath" -f Green
        $c.DownloadFile($uri,$scriptPath)
        . $scriptPath
        $instalationParameters=@{
            InstallationPath=$InstallationPath
            Quiet=$Quiet
        }
        Write-Host "Installation parameters:" -f Yellow
        $instalationParameters|Write-Output
        UninstallXpand @instalationParameters
    }
    
    end {
    }
}

