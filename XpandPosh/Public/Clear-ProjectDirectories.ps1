function Clear-ProjectDirectories() {
    Get-ChildItem -Recurse | 
        Where-Object { $_.PSIsContainer } | 
        Where-Object { $_.Name -eq 'bin' -or $_.Name -eq 'obj' -or $_.Name -eq '.vs' -or $_.Name.StartsWith('_ReSharper')} | foreach{
            (Get-Item $_.FullName).Delete($true)
        }
    Get-ChildItem -Include "*.log", "*.bak" -Recurse | Remove-Item -Force
    $folders = "packages"
    Get-ChildItem -Recurse | 
        Where-Object { $_.PSIsContainer} | 
        Where-Object { $folders -contains $_.Name   } | 
        Remove-Item -Force -Recurse
}