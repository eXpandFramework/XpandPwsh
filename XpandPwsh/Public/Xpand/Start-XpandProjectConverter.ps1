function Start-XpandProjectConverter {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ParameterSetName = "XAFPackages")]
        [string]$version,
        [string]$Path = (Get-Location),
        [parameter()]
        [ValidateSet("csproj", "vbproj")]
        [string]$ProjectType = "csproj",
        [switch]$SkipInstall        
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        [version]$version = Get-DevExpressVersion $version -Build
        "version"|Out-VariableValue
        $paketInstalls = Get-ChildItem $Path ".paket"  -Recurse
        $shortVersion = Get-DevExpressVersion $version 
        if ($paketInstalls) { 
            Get-ChildItem $Path "packages.config"  -Recurse | ForEach-Object {
                "Update DX version in $($_.FullName)"
                [xml]$xml = Get-Content $_
                $xml.packages.package | Where-Object { $_.id -like "DevExpress*" } | ForEach-Object {
                    $_.version = "$version"
                }
                $xml.Save($_)
            }
            $paketInstalls | Select-Object -ExpandProperty Parent | ForEach-Object {
                Push-Location $_.FullName
                Invoke-PaketShowInstalled -OnlyDirect | Where-Object { $_.Id -like "DevExpress*" } | ForEach-Object {
                    $v = New-Object System.Version
                    if ([version]::TryParse($_.version, [ref]$v)) {
                        if ($version -ne $_.version) {
                            Write-Host "Change $($_.Id) $($_.Version) to $version" -f Green
                            $a = @{
                                Id      = $_.Id
                                Version = $version
                                Force   = $SkipInstall
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
                    Invoke-PaketInstall 
                }
                Pop-Location
            }
    
        }
        Get-ChildItem $Path *.csproj -Recurse | ForEach-Object {
            $projectPath = $_.FullName
            "projectPath"|Out-VariableValue
            Remove-Item "$($_.DirectoryName)\properties\licenses.licx" -ErrorAction SilentlyContinue
            if (!(Test-Path "$($_.DirectoryName)\paket.references")) {
                $change = Get-PackageReference $_.FullName | Where-Object { $_.include -like "DevExpress*" } | ForEach-Object {
                    if ($_.Version -ne $version) {
                        Write-Verbose "Change PackageReference $($_.Include) $($_.Version) to $version"
                        $_.Version = $Version.ToString()
                        $element = [System.Xml.XmlElement]$_
                        $element.OwnerDocument.Save($projectPath)
                    }
                }
                if ($change) {
                    Push-Location $_.DirectoryName
                    Clear-ProjectDirectories
                    Pop-Location
                }
                [xml]$proj=Get-Content $projectPath
                Remove-ProjectLicenseFile $proj
                $proj.project.itemgroup.Reference|Where-Object{$_.Include -like "DevExpres*"}|ForEach-Object{
                    if ($_.Version){
                        $_.Version="$version"
                    }
                    elseif ($_.include -like "*,*"){
                        $regex = [regex] '(?n)\.v(?<short>(\d{2}\.\d))'
                        $result = $regex.Replace($_.include, ".v$shortVersion")
                        $regex = [regex] '(?n)=(\d*\.\d*\.\d*\.\d*)'
                        if ($version.Revision -eq -1){
                            $revision=".0"
                        }
                        $result = $regex.Replace($result, "=$version$($revision)")
                        $_.include=$result
                    }
                    
                }
                $proj.Save($projectPath)
            }
            
        }
        $shortDxVersion = Get-DevExpressVersion $Version
        $newVersion = $version.ToString()
        if (($newVersion.ToCharArray() | Where-Object { $_ -eq "." }).Count -eq 2) {
            $newVersion += ".0"
        }
        Write-Verbose "Replace DevExpress existing version with $newVersion to *.aspx, *.config"
        Get-ChildItem $Path -Include "*.aspx", "*.config" -Recurse -File | ForEach-Object {
            $xml = Get-Content $_.FullName -Raw
            $regex = [regex] '(?<name>DevExpress.*)v\d{2}\.\d{1,2}(.*)Version=([.\d]*)'
            $result = $regex.Replace($xml, "`${name}v$shortDxVersion`$1Version=$newVersion")
            Set-Content $_.FullName $result.Trim()
        }        
        Write-Verbose "Replace DevExpress existing packageReference version with $version"
        Get-ChildItem $Path -Include "*.*proj" -Recurse -File | ForEach-Object {
            [xml]$xml = Get-XmlContent $_.FullName 
            $xml.project.itemgroup.PackageReference|Where-Object{$_.Include -like "DevExpress*"}|ForEach-Object{
                $_.Version="$version"
            }
            $xml|Save-Xml $_.FullName|Out-Null
        }
    }
    
    end {
        
    }
}
