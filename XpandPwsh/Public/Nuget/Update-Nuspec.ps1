function Update-Nuspec {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$NuspecFilename,
        [parameter(Mandatory)]
        [string]$ProjectFileName,
        [string]$ReferenceToPackageFilter = "*",
        [string]$PublishedSource,
        [switch]$Release,
        [switch]$ReadMe,
        [string]$LibrariesFolder = "..\src\libs"
    )
    
    begin {
    }
    
    process {
        [xml]$csproj = Get-Content $ProjectFileName
        [xml]$nuspec = Get-Content $NuspecFilename
        $ns = New-Object System.Xml.XmlNamespaceManager($nuspec.NameTable)
        $ns.AddNamespace("ns", $nuspec.DocumentElement.NamespaceURI)
        $AddDependency = {
            param($psObj)
            $dependency = $nuspec.CreateElement("dependency", $nuspec.DocumentElement.NamespaceURI)
            $dependency.SetAttribute("id", $psObj.id)
            $dependency.SetAttribute("version", $psObj.version)
            $nuspec.SelectSingleNode("//ns:dependencies", $ns).AppendChild($dependency)
        }
        $NuspecsDirectory = (Get-Item $NuspecFilename).DirectoryName
        $projectDirectory = ((Get-Item $ProjectFileName).DirectoryName)
        $id = (get-item $ProjectFileName).BaseName.Trim()

        $nuspecPath=[System.IO.Path]::GetFullPath("$($csproj.Project.PropertyGroup.OutputPath)\$id.dll")
        $nuspec.package.metadata.version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($nuspecPath).FileVersion
        $nuspec.Save($NuspecFilename)
        $csproj.Project.ItemGroup.Reference | Where-Object { "$($_.Include)" -like $ReferenceToPackageFilter } | ForEach-Object {
            $packageName = $_.Include
            $comma = $packageName.IndexOf(",")
            if ($comma -ne -1 ) {
                $packageName = $packageName.Substring(0, $comma)
            }
            $packageName = Get-ChildItem $NuspecsDirectory *.nuspec | ForEach-Object {
                [xml]$xml = Get-Content $_.FullName
                $match = $xml.package.files.file.src | Select-String "$packageName.dll"
                if ($match) {
                    $xml.package.metaData.id
                    break
                }
            } | Select-Object -First 1
           
            Push-Location $projectDirectory
            $packagePath = Resolve-Path $_.HintPath
            Pop-Location
            $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$packagePath").FileVersion
            $packageInfo = [PSCustomObject]@{
                id              = $packageName
                version         = $version
            }       
            Invoke-Command $AddDependency -ArgumentList $packageInfo
            $nuspec.Save($NuspecFilename)
           
        }
        $nuspec.Save($NuspecFilename)
        $packageReference = $csproj.Project.ItemGroup.PackageReference
        $targetFrameworkVersion = ($csproj.Project.PropertyGroup.TargetFramework | Select-Object -First 1).Substring(3)
        $projectpath
        $packageReference | Where-Object { $_.Include } | ForEach-Object {
            $packageInfo = [PSCustomObject]@{
                Id              = $_.Include
                Version         = $_.Version
            }
            Invoke-Command $AddDependency -ArgumentList $packageInfo 
        }
        
        "dll", "pdb" | ForEach-Object {
            $file = $nuspec.CreateElement("file", $nuspec.DocumentElement.NamespaceURI)
            $file.SetAttribute("src", "$id.$_")
            $file.SetAttribute("target", "lib\net$targetFrameworkVersion\$id.$_")
            $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null
        }
    
        [System.Environment]::CurrentDirectory = $projectDirectory
        $csproj.Project.ItemGroup.Reference.HintPath | ForEach-Object {
            if ($_) {
                $hintPath = [System.IO.Path]::GetFullPath($_)
                $hintPath
                if (Test-Path $hintPath) {
                    if ($libs | Select-Object -ExpandProperty FullName | Where-Object { $_ -eq $hintPath }) {
                        $file = $nuspec.CreateElement("file")
                        $libName = (Get-item $hintpath).Name
                        $file.SetAttribute("src", "$LibrariesFolder\$libName")
                        
                        $file.SetAttribute("target", "lib\net$targetFrameworkVersion\$libName")
                        $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null    
                    }
                }
            }
            
        }
    
        if ($ReadMe) {
            $file = $nuspec.CreateElement("file", $nuspec.DocumentElement.NamespaceURI)
            $file.SetAttribute("src", "Readme.txt")
            $file.SetAttribute("target", "")
            $nuspec.SelectSingleNode("//ns:files", $ns).AppendChild($file) | Out-Null
        }
    
        $uniqueDependencies=$nuspec.package.metadata.dependencies.dependency|Sort-Object Id -Unique
        $nuspec.package.metadata.dependencies.RemoveAll()
        $uniqueDependencies|ForEach-Object{Invoke-Command $AddDependency -ArgumentList $_}
        $nuspec.Save($NuspecFilename)
    }
    
    end {
    }
}

