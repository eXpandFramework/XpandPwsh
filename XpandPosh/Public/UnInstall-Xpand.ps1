param (
    $InstallationPath=$PSScriptRoot
)
Write-host "UnInstalling from GAC" -f Blue
& "$InstallationPath\Xpand.Dll\GAcInstaller" -m UnInstall
Write-host "Deleting registry keys" -f Blue
$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
$subKey =  $key.OpenSubKey("SOFTWARE\Microsoft\.NETFramework\AssemblyFolders",$true)
$subKey.DeleteSubKey("Xpand2");
Write-host "Removing $InstallationPath" -f Blue
Remove-Item $InstallationPath -Recurse -Force