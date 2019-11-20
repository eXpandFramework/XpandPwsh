function Start-XpandProjectConverter {
    [CmdletBinding()]
    param (
        [parameter(ParameterSetName = "XAFPackages")]
        [string]$version,
        [parameter(ParameterSetName = "XAFPackages")]
        [string]$Packagepath,
        [string]$Path = (Get-Location),
        [parameter()]
        [ValidateSet("csproj", "vbproj")]
        [string]$ProjectType = "csproj",
        [switch]$SkipInstall
    )
    
    if (!$Version) {
        $xpandPath = Get-XpandPath
        $packages = Get-ChildItem $xpandPath "Xpand*.dll" | ForEach-Object {
            $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_.FullName).FileVersion
            [PSCustomObject]@{
                Id      = $_.BaseName
                Version = $version
            }
        }
        Get-ChildItem $Path "*.$ProjectType" -Recurse | ForEach-Object {
            [xml]$csproj = Get-Content $_.FullName
            $csproj.Project.ItemGroup.Reference | Where-Object { $_.include -like "Xpand*" } | ForEach-Object {
                $regex = [regex] '(?ix)([^,"]*)'
                $result = $regex.Match($_.Include).Value;
                $package = $packages | Where-Object { $_.Id -eq $result }
                $_.Include = "$result, Version=$($package.Version), Culture=neutral, PublicKeyToken=c52ffed5d5ff0958, processorArchitecture=MSIL"
            }
            $csproj.Save($_.FullName)
        }
    }
    else {
        [version]$version = Get-DevExpressVersion $version -Build
        $paketInstalls = Get-ChildItem $Path ".paket"  -Recurse
        $shortVersion = Get-DevExpressVersion $version 
        if ($paketInstalls) { 
            Get-ChildItem $Path "packages.config"  -Recurse|ForEach-Object{
                "Update DX version in $($_.FullName)"
                [xml]$xml=Get-Content $_
                $xml.packages.package|Where-Object{$_.id -like "DevExpress*"}|ForEach-Object{
                    $_.version=$version
                }
                $xml.Save($_)
            }
            $paketInstalls | Select-Object -ExpandProperty Parent | ForEach-Object {
                Push-Location $_
                Invoke-PaketShowInstalled -OnlyDirect| Where-Object { $_.Id -like "DevExpress*" } | ForEach-Object {
                    $v = New-Object System.Version
                    if ([version]::TryParse($_.version, [ref]$v)) {
                        if ($version -ne $_.version){
                            "Change $($_.Id) $($_.Version) to $version"
                            $a=@{
                                Id=$_.Id
                                Version=$version
                                Force=$SkipInstall
                            }
                            Invoke-PaketUpdate @a
                        }
                    }
                }
                $regex = [regex] '(source .*)(DevExpress \d{2}\.\d)'
                $deps = Get-Content "$($_.FullName)\paket.dependencies" -Raw
                $result = $regex.Replace($deps, "`$1\DevExpress $shortVersion")
                Set-Content "$($_.FullName)\paket.dependencies" $result
                if (!$SkipInstall) {
                    Invoke-PaketInstall $_ 
                }
                Pop-Location
            }

        }
        else {
            Get-ChildItem $Path *.csproj -Recurse | ForEach-Object {
                $projectPath = $_.FullName
                Get-PackageReference $_.FullName | Where-Object { $_.include -like "DevExpress*" } | ForEach-Object {
                    if ($_.Version -ne $version) {
                        "Change $($_.Include) $($_.Version) to $version"
                        $_.Version = $Version
                        $element = [System.Xml.XmlElement]$_
                        $element.OwnerDocument.Save($projectPath)
                    }
                }
            }
        }
        if ($Packagepath) {
            Switch-XpandToNugets -Path $Path -PackageSource $Packagepath
        }
    }
}