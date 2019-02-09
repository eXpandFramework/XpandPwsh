function Install-Chocolatey {    
    "verifying chocolatey is installed"
    if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
        "installing chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        if (!(Test-path "$env:ChocolateyPath\lib")){
            New-Item "$env:ChocolateyPath\lib" -ItemType Directory
        }
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    else {
        "chocolatey is already installed"
    }   
}

function Get-ChocoPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $filter
    )
    
    begin {
    }
    
    process {
        choco list $filter --lo|Where{$_ -like "$filter *"}|ForEach-Object{
            $strings=$_.split(";")
            [PSCustomObject]@{
                Name = $strings[0]
                Version =$strings[1]
            }
        }
    }
    
    end {
    }
}

function Install-NugetCommandLine{
    Install-Chocolatey
    if (!(Get-ChocoPackage Nuget.CommandLine)){
        cinst NuGet.CommandLine
    }
}