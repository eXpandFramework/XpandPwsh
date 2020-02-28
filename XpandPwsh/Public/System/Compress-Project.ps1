function Compress-Project {
    [CmdLetTag()]
    param(
        $path=(Get-Location)
    )
    Clear-ProjectDirectories $path
    $tempName=[guid]::NewGuid()
    Compress-Archive $path "$env:TEMP\$tempName.zip"
    $dir=(get-item $path)
    Copy-Item "$env:TEMP\$tempName.zip" "$path\$($dir.Name).zip"
}