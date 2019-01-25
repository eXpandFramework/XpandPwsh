function Get-XpandVersion ($XpandPath) { 
    $assemblyInfo="$XpandPath\Xpand\Xpand.Utils\Properties\XpandAssemblyInfo.cs"
    $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String 'public const string Version = \"([^\"]*)'
    if ($matches) {
        return $matches[0].Matches.Groups[1].Value
    }
    else{
        Write-Error "Version info not found in $assemblyInfo"
    }
}

function Get-VersionFromFile([parameter(mandatory)][string]$assemblyInfo){
    $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String 'public const string Version = \"([^\"]*)'
    if ($matches) {
        $matches[0].Matches.Groups[1].Value
    }
    else{
        throw "Version info not found in $assemblyInfo"
    }
}

function Get-DXVersion([string]$version,[switch]$build){
    $v=New-Object System.Version $version
    if (!$build){
        "$($v.Major).$($v.Minor)"
    }    
    else{
        "$($v.Major).$($v.Minor).$($v.Build.ToString().Substring(0,1))"
    }
}

function Update-AssemblyInfoBuild($path){
    if (!$path){
        $path= "."
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object{
        $c=Get-Content $_.FullName
        $value=[System.text.RegularExpressions.Regex]::Match($c,"[\d]{1,2}\.[\d]{1}\.[\d]*(\.[\d]*)?").Value
        $version=New-Object System.Version ($value)
        $newBuild=$version.Build+1
        $newVersion=new-object System.Version ($version.Major,$version.Minor,$newBuild,0)
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$newVersion"
        Set-Content $_.FullName $result
    }
}
function Update-AssemblyInfoVersion([parameter(mandatory)]$version,$path){
    if ($path -eq $null){
        $path= "."
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object{
        $c=Get-Content $_.FullName
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$version"
        Set-Content $_.FullName $result
    }
}