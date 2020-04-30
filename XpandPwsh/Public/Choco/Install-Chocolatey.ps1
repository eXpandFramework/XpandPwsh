
function Install-Chocolatey {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        [switch]$AllowGlobalConfirmation
    )
    
    begin {
        
    }
    
    process {
        if (!(Test-ChocoInstalled)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force;
            if (!(Test-path "$env:ChocolateyPath\lib")){
                New-Item "$env:ChocolateyPath\lib" -ItemType Directory
            }
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        if ($AllowGlobalConfirmation){
            choco feature enable -n=allowGlobalConfirmation
        }
    }
    
    end {
        
    }
}