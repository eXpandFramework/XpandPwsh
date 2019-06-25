function Update-Nuspec {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$NuspecFilename,
        [parameter(Mandatory)]
        [string]$ProjectFileName,
        [parameter(Mandatory)]
        [string]$ProjectsRoot,
        [string]$ReferenceToPackageFilter = "*",
        [string]$PublishedSource,
        [switch]$Release,
        [switch]$ReadMe,
        [string]$NuspecMatchPattern,   
        [string]$LibrariesFolder ,
        $customPackageLinks = @{ },
        [switch]$KeepDependencies,
        [switch]$KeepFiles,
        [bool]$ResolveNugetDependecies
    )
    
    begin {
    }
    
    process {
        [xml]$csproj = Get-Content $ProjectFileName
        [xml]$nuspec = Get-Content $NuspecFilename
        if (!$KeepDependencies) {
            if ($nuspec.package.metadata.dependencies) {
                $nuspec.package.metadata.dependencies.RemoveAll()
            }
        }
        if (!$KeepFiles) {
            if ($nuspec.package.files) {
                $nuspec.package.files.RemoveAll()
            }
        }
        $nuspec.Save($NuspecFilename)
        $ns = New-Object System.Xml.XmlNamespaceManager($nuspec.NameTable)
        $ns.AddNamespace("ns", $nuspec.DocumentElement.NamespaceURI)
        $AddDependency = {
            param($psObj)
            $dependency = $nuspec.CreateElement("dependency", $nuspec.DocumentElement.NamespaceURI)
            $dependency.SetAttribute("id", $psObj.id)
            $dependency.SetAttribute("version", $psObj.version)
            $nuspec.SelectSingleNode("//ns:dependencies", $ns).AppendChild($dependency) | Out-Null
        }
        $NuspecsDirectory = (Get-Item $NuspecFilename).DirectoryName
        $projectDirectory = ((Get-Item $ProjectFileName).DirectoryName)
        $id = (get-item $ProjectFileName).BaseName.Trim()
        Push-Location $projectDirectory
        $outputPath = $csproj.Project.PropertyGroup.OutputPath | Select-Object -First 1
        if (!$outputPath) {
            throw "$ProjectFileName outputpath not set"
        }
        $outputPath = "$(Resolve-Path $outputPath)"
        Pop-Location
        $assemblyPath = "$outputPath\$id.dll"
        $allDependencies=@()
        if ($ResolveNugetDependecies){
            $allDependencies = [System.Collections.ArrayList]::new((Resolve-AssemblyDependencies $assemblyPath -ErrorAction SilentlyContinue | ForEach-Object { $_.GetName().Name }))
        }

        $nuspec.package.metadata.version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($assemblyPath).FileVersion
        
        $csproj.Project.ItemGroup.Reference | Where-Object { "$($_.Include)" -like $ReferenceToPackageFilter } | ForEach-Object {
            $packageName = $_.Include
            $comma = $packageName.IndexOf(",")
            if ($comma -ne -1 ) {
                $packageName = $packageName.Substring(0, $comma)
            }
            if (!$ResolveNugetDependecies -or $packageName -in $allDependencies) {
                $matchedPackageName = $customPackageLinks[$packageName]
                if (!$matchedPackageName) {
                    $projectName = Get-ChildItem $ProjectsRoot *.csproj -Recurse | Select-Object -ExpandProperty BaseName | Where-Object { $_ -eq $packageName } | Select-Object -First 1
                    $regex = [regex] $NuspecMatchPattern
                    $projectName = $regex.Replace($projectName, '') 
                    $matchedPackageName = Get-ChildItem $NuspecsDirectory *.nuspec | Where-Object { $_.BaseName -eq $projectName }
                    if (!$matchedPackageName) {
                        throw "$packageName not matched in $NuspecFilename"
                    }
                    [xml]$xml = Get-Content $matchedPackageName.FullName
                    $matchedPackageName = $xml.package.metadata.id
                }
                if ($matchedPackageName -ne $nuspec.package.metadata.Id) {
                    Push-Location $projectDirectory
                    $packagePath = Resolve-Path $_.HintPath
                    Pop-Location
                    $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$packagePath").FileVersion
                    $packageInfo = [PSCustomObject]@{
                        id      = $matchedPackageName
                        version = $version
                    }       
                    Invoke-Command $AddDependency -ArgumentList $packageInfo
                }
                
                $nuspec.Save($NuspecFilename)
            }
        }
        
        $packageReference = $csproj.Project.ItemGroup.PackageReference
        $targetFrameworkVersion = ($csproj.Project.PropertyGroup.TargetFramework | Select-Object -First 1).Substring(3)
        
        $packageReference | Where-Object { $_.Include -and $_.PrivateAssets -ne "all" } | ForEach-Object {
            $packageInfo = [PSCustomObject]@{
                Id      = $_.Include
                Version = $_.Version
            }
            if (!$ResolveNugetDependecies -or $_.Include -in $allDependencies) {
                Invoke-Command $AddDependency -ArgumentList $packageInfo 
            }
        }
        $nuspec.Save($NuspecFilename)
        "dll", "pdb" | ForEach-Object {
            $file = $nuspec.CreateElement("file", $nuspec.DocumentElement.NamespaceURI)
            $file.SetAttribute("src", "$id.$_")
            $file.SetAttribute("target", "lib\net$targetFrameworkVersion\$id.$_")
            $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null
        }
        $nuspec.Save($NuspecFilename)
        if ($LibrariesFolder) {
            [System.Environment]::CurrentDirectory = $projectDirectory
            $libs = Get-ChildItem $LibrariesFolder *.dll
            $csproj.Project.ItemGroup.Reference.HintPath | ForEach-Object {
                if ($_) {
                    Push-Location $projectDirectory
                    $hintPath = Resolve-Path $_
                    Pop-Location
                    if (Test-Path $hintPath) {
                        if ($libs | Select-Object -ExpandProperty FullName | Where-Object { $_ -eq $hintPath }) {
                            $file = $nuspec.CreateElement("file")
                            $libName = (Get-item $hintpath).Name
                            $relativePath = Get-RelativePath "$outputPath\$libname" "$LibrariesFolder"
                            $file.SetAttribute("src", "$relativePath\$libname")
                        
                            $file.SetAttribute("target", "lib\net$targetFrameworkVersion\$libName")
                            $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null    
                        }
                    }
                }
            
            }
        }
        $nuspec.Save($NuspecFilename)
        if ($ReadMe) {
            $file = $nuspec.CreateElement("file", $nuspec.DocumentElement.NamespaceURI)
            $file.SetAttribute("src", "Readme.txt")
            $file.SetAttribute("target", "")
            $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null
        }
    
        $uniqueDependencies = $nuspec.package.metadata.dependencies.dependency | Where-Object { $_.id } | Sort-Object Id -Unique
        $nuspec.package.metadata.dependencies.RemoveAll()
        
        $uniqueDependencies
        $uniqueDependencies | ForEach-Object { Invoke-Command $AddDependency -ArgumentList $_ }
        $nuspec.Save($NuspecFilename)
    }
    
    end {
    }
}

