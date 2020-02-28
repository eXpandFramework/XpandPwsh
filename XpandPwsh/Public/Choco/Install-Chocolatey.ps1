
function Install-Chocolatey {
    [CmdletBinding()]
    [CmdLetTag("#chocolatey")]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        "verifying chocolatey is installed"
        if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
            "installing chocolatey..."
            Set-ExecutionPolicy Bypass -Scope Process -Force;
            if (!(Test-path "$env:ChocolateyPath\lib")){
                New-Item "$env:ChocolateyPath\lib" -ItemType Directory
            }
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        else {
            "chocolatey is already installed"
        }          
    }
    
    end {
        
    }
}