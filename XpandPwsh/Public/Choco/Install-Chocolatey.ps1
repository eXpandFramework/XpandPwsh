
function Install-Chocolatey {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        [switch]$AskConfirmation
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
        if (!$AskConfirmation){
            choco feature enable -n=allowGlobalConfirmation
        }
    }
    
    end {
        
    }
}