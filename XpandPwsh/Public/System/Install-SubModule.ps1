function Install-SubModule{
    [CmdLetTag()]
    param(
        [string]$Name,
        [string[]]$Files,
        [string[]]$Packages
    )
    if (!(Get-Module $Name -ListAvailable)){
        Write-Host "Installing $Name"
        $installationPath="$($env:PSModulePath -split ";"|where-object{$_ -like "$env:USERPROFILE*"}|Select-Object -Unique)\$Name"
        New-Item $installationPath -ItemType Directory -Force
        New-Assembly -AssemblyName $Name -Files $Files -Packages $Packages -outputpath $installationPath
    }
}
