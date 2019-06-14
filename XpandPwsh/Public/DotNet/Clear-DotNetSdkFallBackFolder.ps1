function Clear-DotNetSdkFallBackFolder() {
    Get-ChildItem ${env:ProgramFiles(x86)}\dotnet\sdk\NugetFallbackFolder |ForEach-Object{
        Remove-Item $_.FullName -Force -Recurse
    }
}
