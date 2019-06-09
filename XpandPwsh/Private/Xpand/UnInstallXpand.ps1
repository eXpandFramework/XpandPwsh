function UnInstallXpand {
    param (
        [string]$InstallationPath,
        [switch]$Quiet
    )
    $ErrorActionPreference = "Stop"
    [Net.ServicePointManager]::Expect100Continue = $true
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $isElevated=[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    if (!$isElevated){
        throw "The script needs administrator rights. Right click on the powershell icon and choose run as Administrator"
    }        
    $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
    $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\Xpand", $true)
    if (!$InstallationPath -and !$subKey) {
        throw "HKLM:\\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\Xpand not exists"
    }
    if (!$InstallationPath -and $subKey) {
        $InstallationPath = "$($subkey.GetValue(''))\.."
    }

    if (!(Test-Path $InstallationPath)) {
        throw "Installtion path $InstallationPath is not valid"
    }
    $InstallationPath = [System.IO.Path]::GetFullPath($InstallationPath)
    if (!$Quiet){
        Write-host "Xpand found in $InstallationPath. All contetns will be deleted. Press any key to continue." -f Yellow    
        Read-Host
    }

    $count = (Get-ChildItem "$InstallationPath\Xpand.DLL" *.dll).Count
    Write-Progress -Activity gacInstaller -Status "Uninstalling assemblies from GAC"
    $i = 0
    & "$InstallationPath\Xpand.Dll\GAcInstaller.exe" -m UnInstall|ForEach-Object {
        if ($_ -like "*Number of assemblies uninstalled =*") {
            Invoke-Command  {
                $ErrorActionPreference="SilentlyContinue"
                Write-Progress -Activity gacInstaller -Status $_ -PercentComplete $($i * 100 / $count)
            } 
            $i++
        }
        $_
    }
    Write-Progress -Activity gacInstaller -Status "Finish GAC uninstalltion" -Completed

    Write-host "Deleting registry keys" -f Green
    if ($subKey) {
        $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders", $true).DeleteSubKey("Xpand");
    }
        
    Write-host "Removing $InstallationPath." -f Yellow

    [System.IO.Directory]::Delete($InstallationPath, $true)
    Write-host "$InstallationPath removed" -f Green

    Write-Host "Uninstalling Xpand.VSIX" -ForegroundColor Blue
    "Local","Roaming"|ForEach-Object{
        Get-ChildItem "$env:USERPROFILE\AppData\$_\Microsoft\VisualStudio" Xpand.VSIX.pkgdef -Recurse|ForEach-Object{
            $directory=[System.IO.Path]::GetFullPath("$($_.DirectoryName)")
            Write-Host "Found in $directory" -f Green
            Get-ChildItem $directory -Recurse|Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    
}