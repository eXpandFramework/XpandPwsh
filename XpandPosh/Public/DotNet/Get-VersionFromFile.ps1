function Get-VersionFromFile([parameter(mandatory)][string]$assemblyInfo) {
    $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String 'public const string Version = \"([^\"]*)'
    if ($matches) {
        $matches[0].Matches.Groups[1].Value
    }
    else {
        throw "Version info not found in $assemblyInfo"
    }
}