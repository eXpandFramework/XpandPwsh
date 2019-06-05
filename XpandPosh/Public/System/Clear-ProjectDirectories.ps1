function Clear-ProjectDirectories {
    param(
        $path=(Get-Location)
    )
    Get-ChildItem $path -Recurse | 
        Where-Object { $_.PSIsContainer } | 
        Where-Object { $_.Name -eq 'bin' -or $_.Name -eq 'obj' -or $_.Name -eq '.vs' -or $_.Name.StartsWith('_ReSharper')} | ForEach-Object{
            (Get-Item $_.FullName).Delete($true)
        }
    Get-ChildItem $path -Include "*.log", "*.bak" -Recurse | Remove-Item -Force
    $folders = "packages"
    Get-ChildItem $path -Recurse | 
        Where-Object { $_.PSIsContainer} | 
        Where-Object { $folders -contains $_.Name   } | 
        Remove-Item -Force -Recurse
}