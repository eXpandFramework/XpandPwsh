function Get-DotNetCoreVersion {
    param(
        [validateset("Runtime", "SDK")]
        [string]$Type
    )
    if ($type -eq "Runtime") {
        dotnet --list-runtimes|ForEach-Object {
            $r = new-object Regex ("(?<Name>[^ ]*) (?<Version>[^ ]*) \[(?<Path>[^\]]*)")
            $m = $r.Match($_)
            [PSCustomObject]@{
                Name    = $m.Groups["Name"].Value
                Version = $m.Groups["Version"].Value
                Path    = $m.Groups["Path"].Value
            }
        }
    }
    else {
        dotnet --list-sdks|ForEach-Object {
            $r = new-object Regex ("(?<Name>[^ ]*) \[(?<Path>[^\]]*)")
            $m = $r.Match($_)
            [PSCustomObject]@{
                Name    = $m.Groups["Name"].Value
                Version = $m.Groups["Name"].Value
                Path    = $m.Groups["Path"].Value
            }
        }
    }
}