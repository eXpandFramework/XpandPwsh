function Update-AssemblyInfoVersion([parameter(mandatory)]$version, $path) {
    if (!$path) {
        $path = "."
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object {
        $c = Get-Content $_.FullName
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$version"
        Set-Content $_.FullName $result
    }
}