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
        if (!$InstallationPath -and !$subKey) {
            throw "HKLM:\\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\Xpand not exists"
        }
        $InstallationPath = "$($subkey.GetValue(''))\.."
        Write-host "Xpand found in $InstallationPath" -f Green    
        $InstallationPath=[System.IO.Path]::GetFullPath($InstallationPath)
        $count=(Get-ChildItem "$InstallationPath\Xpand.DLL" *.dll).Count
        Write-Progress -Activity gacInstaller -Status "Uninstalling assemblies from GAC"
        $i=0
        & "$InstallationPath\Xpand.Dll\GAcInstaller.exe" -m UnInstall|ForEach-Object{
            if ($_ -like "*Number of assemblies uninstalled =*"){
                $i++;
                [int]$completed=$i*100/$count
                if ($completed -lt 100){
                    Write-Progress -Activity gacInstaller -Status $_ -PercentComplete $completed
                }
            }
            $_
        }
        Write-Progress -Activity gacInstaller -Status "Finish GAC uninstalltion" -Completed

        Write-host "Deleting registry keys" -f Green
        if ($subKey) {
            $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders", $true).DeleteSubKey("Xpand");
        }
        
        Write-host "Removing $InstallationPath" -f Green
        [System.IO.Directory]::Delete($InstallationPath,$true)
        Write-host "$InstallationPath removed" -f Green
        $bootstrapper="$env:TEMP\VSIXBootstrapper.exe"
        if (!(Test-Path $bootstrapper)){
            Invoke-WebRequest -Uri "https://github.com/Microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe" -OutFile $bootstrapper
        }
        & $bootstrapper "/u:Xpand.VSIX.eXpandFramework.4ab62fb3-4108-4b4d-9f45-8a265487d3dc"
        
    }
    
    end {
    }
}

