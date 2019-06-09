function Get-RelativePath($fileName,$targetPath) {
    $location=Get-Location
    Set-Location $((get-item $filename).DirectoryName)
    $path=Resolve-Path $targetPath -Relative
    Set-Location $location
    return $path
}