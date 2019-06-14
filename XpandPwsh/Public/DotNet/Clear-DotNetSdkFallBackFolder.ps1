function Clear-DotNetSdkFallBackFolder() {
    $path=(Get-DotNetCoreVersion|Select-Object -First 1).path
    Get-ChildItem "$path\NugetFallbackFolder" |ForEach-Object{
        Remove-Item $_.FullName -Force -Recurse
    }
}
