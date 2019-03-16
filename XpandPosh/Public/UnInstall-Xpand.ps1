function UnInstall-Xpand {
    [CmdletBinding()]
    param (
        [string]$InstallationPath    
    )
    
    begin {
    }
    
    process {
        $key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $subKey = $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\Xpand", $true)
        if (!$InstallationPath) {
            if (!$subKey) {
                Write-Host "HKLM:\\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\Xpand not exists" -f Red
            }
            $InstallationPath = "$($subkey.GetValue(''))\.."
            Write-host "Xpand found in $InstallationPath" -f Blue    
        }
        
        Write-host "UnInstalling from GAC" -f Blue
        & "$InstallationPath\Xpand.Dll\GAcInstaller.exe" -m UnInstall
        Write-host "Deleting registry keys" -f Blue
        if ($subKey) {
            $subKey.DeleteSubKey("Xpand");
        }
        
        & "$InstallationPath\VSIXBootstrapper.exe" "/u:""Xpand.VSIX.eXpandFramework.4ab62fb3-4108-4b4d-9f45-8a265487d3dc"""
        Write-host "Removing $InstallationPath" -f Blue
        Remove-Item $InstallationPath -Recurse -Force
        Remove-Item "$InstallationPath\VSIXBootstrapper.exe"
    }
    
    end {
    }
}
