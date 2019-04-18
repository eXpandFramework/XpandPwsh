function Get-XpandPath() {
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432node\Microsoft\.NETFramework\AssemblyFolders\Xpand').'(default)'
}
