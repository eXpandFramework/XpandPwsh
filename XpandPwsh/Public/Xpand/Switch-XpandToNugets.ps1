function Switch-XpandToNugets {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$Path=".",
        [parameter()]
        [string]$PackageSource=(Get-PackageFeed -Nuget)
    )
    
    begin {
        
    }
    
    process {
        $pObjects = Get-XpandPackages -Source Lab|Where-Object{$_.id -like "*xpand*"}
        $packages = $pObjects | Invoke-Parallel -VariablesToImport "PackageSource" -Script { 
        # $packages = $pObjects | foreach { 
            $downloadResult=(Get-NugetPackage  -Name $_.id -ResultType DownloadResults -Source $PackageSource )
            [PSCustomObject]@{
                DownloadResult = $downloadResult
                Version        = ([xml](Get-Content $downloadResult.PackageReader.GetNuspecFile())).package.metadata.version
            }
        } | ForEach-Object {
            $packageReader = $_.DownloadResult.PackageReader
            $version = $_.Version
            $packageReader.GetLibItems().Items | ForEach-Object {
                [PSCustomObject]@{
                    Id       = $packageReader.NuspecReader.GetIdentity().Id
                    FileName = [System.IO.Path]::GetFileNameWithoutExtension($_)
                    Version  = $version
                }    
            }
        } | Sort-Object FileName -Unique
        $packages
        Get-ChildItem $Path *.*proj -Recurse | ForEach-Object {
            [xml]$csproj = Get-Content $_
            $projectPath = $_.FullName
            $csproj.Project.ItemGroup.Reference | Where-Object { $_.include -like "Xpand*" } | ForEach-Object {
                $include = $_.include
                if ($include.Contains(",")) {
                    $include = $include.SubString(0, $include.IndexOf(","))
                }
                $package = $packages | Where-Object { $_.FileName -eq $include }
                if (!$package) {
                    throw "$($_.include) not found"
                }
                $group = $_.ParentNode
                Add-XmlElement $csproj "PackageReference" "ItemGroup" ([ordered]@{
                    Include=$package.Id
                    Version = $package.Version
                })
                $group.RemoveChild($_)
            }
            $projectPath | Remove-BlankLines
            $csproj.Save($_)
            Clear-ProjectDirectories $projectPath
        }
    }
    
    end {
        
    }
}
