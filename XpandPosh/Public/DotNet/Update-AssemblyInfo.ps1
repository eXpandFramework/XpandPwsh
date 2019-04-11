function Update-AssemblyInfo() {
    param(
        [parameter(Mandatory)]
        $path,
        [switch]$Build,
        [switch]$Minor

    )
    if (!$path) {
        $path = get-location
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object {
        $c = Get-Content $_.FullName
        $value = [System.text.RegularExpressions.Regex]::Match($c, "[\d]{1,2}\.[\d]{1}\.[\d]*(\.[\d]*)?").Value
        $version = New-Object System.Version ($value)
        $newBuild = $version.Build 
        if ($Build){
            $newBuild=$version.Build + 1
        }
        $newMinor = $version.Minor 
        if ($Minor){
            $newMinor=$version.Minor + 1
            if (!$Build){
                $newBuild=0
            }
        }
        $newVersion = new-object System.Version ($version.Major, $newMinor, $newBuild, 0)
        $parentDir=(Get-Item $_.DirectoryName).Parent.Name
        "$parentDir new version is $newVersion "
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$newVersion"
        Set-Content $_.FullName $result
    }
}