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
        $path= get-location
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object{
        $c=Get-Content $_.FullName
        $value=[System.text.RegularExpressions.Regex]::Match($c,"[\d]{1,2}\.[\d]{1}\.[\d]*(\.[\d]*)?").Value
        $version=New-Object System.Version ($value)
        $newBuild=$version.Build+1
        $newVersion=new-object System.Version ($version.Major,$version.Minor,$newBuild,0)
        "$_ new version is $newVersion "
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$newVersion"
        Set-Content $_.FullName $result
    }
}
function Update-AssemblyInfoVersion([parameter(mandatory)]$version,$path){
    if (!$path){
        $path= "."
    }
    Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object{
        $c=Get-Content $_.FullName
        $result = $c -creplace 'Version\("([^"]*)', "Version(""$version"
        Set-Content $_.FullName $result
    }
}

Function Update-SpecificVersions {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline, Mandatory)]
        [string]$fiLeName,
        [parameter(Mandatory)]
        [string]$filter,
        [parameter()]
        [string]$binPath
    )

    Process {
        $project = [xml](Get-Content $fiLeName)
        $ns = New-Object System.Xml.XmlNamespaceManager($project.NameTable)
        $ns.AddNamespace("ns", $project.DocumentElement.NamespaceURI)
        $xPath = "//ns:Reference[contains(@Include,$filter)]"
        $references = $project.SelectNodes($xPath, $ns)
        $references | ForEach-Object {
            $assemblyName = $_.Include
            if ($_.Include.IndexOf(",") -gt 0) {
                $assemblyName = $_.Include.Substring(0, $_.Include.IndexOf(","))
                if ($_.Include -imatch '.*Version=([^,]*),.*') {
                    $version = $Matches[1]
                    $_.Include = $_.Include.Replace($version, $(Get-XpandVersion))
                }
            }
            $n = $_.SelectSingleNode("ns:SpecificVersion", $ns)
            if (!$n) {
                $n = $project.CreateElement("SpecificVersion", $project.DocumentElement.NamespaceURI)
                $_.AppendChild($n)
            }
            $n.InnerText = "False"

            $n = $_.SelectSingleNode("ns:HintPath", $ns)
            if (Test-Path $binpath){
                if (!$n) {
                    $n = $project.CreateElement("HintPath", $project.DocumentElement.NamespaceURI)
                    $_.AppendChild($n)
                }
            
                $n.InnerText = "$binPath\$assemblyName.dll"
            }
            else{
                if ($n){
                    $n.ParentNode.RemoveChild($n)
                }
            }
        }
        
        $project.Save($fiLeName)
    }
}
}