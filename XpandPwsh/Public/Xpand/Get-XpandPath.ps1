function Get-XpandPath() {
    [CmdLetTag()]
    param()
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432node\Microsoft\.NETFramework\AssemblyFolders\Xpand' -ErrorAction SilentlyContinue).'(default)'
}
