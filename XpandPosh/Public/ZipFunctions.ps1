function Compress-Project() {
    Get-ChildItem -Recurse | 
        Where-Object { $_.PSIsContainer } | 
        Where-Object { $_.Name -eq 'bin' -or $_.Name -eq 'packages' -or $_.Name -eq 'obj' -or $_.Name -eq '.vs' -or $_.Name.StartsWith('_ReSharper')} | 
        Remove-Item -Force -Recurse 
    
    $zipFileName = [System.IO.Path]::Combine($currentLocation, $zipFileName)
    Compress-Archive -DestinationPath $zipFileName -Path .
}