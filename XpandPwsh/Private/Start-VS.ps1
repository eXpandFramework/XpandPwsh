$isElevated = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if (!$isElevated) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Run as Admin')
}
    
$env:COMPLUS_ZapDisable = 1
    
Push-Location 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\'
move-item devenv.exe _devenv.exe
& $args[0] $args[1]
move-item _devenv.exe devenv.exe