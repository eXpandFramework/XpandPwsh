function Switch-XpandToNugets {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Path,
        [parameter(Mandatory)]
        [string]$PackageSource
    )
    
    begin {
        
    }
    
    process {
        $packages = & (Get-NugetPath) list -source $PackageSource|ConvertTo-PackageObject
        Get-ChildItem $Path *.*proj -Recurse -Exclude "*Tests*" | ForEach-Object {
            [xml]$csproj = Get-Content $_
            $projectPath=$_.FullName
            $csproj.Project.ItemGroup.Reference | Where-Object { $_.include -like "Xpand*" } | ForEach-Object {
                $packageReference = $csproj.CreateElement("PackageReference")
                $packageReference.SetAttribute("Include", $_.Include)
                $package = $packages | Where-Object { $_.Id -eq $packageReference.include }
                if (!$package){
                    throw "$($_.include) not found"
                }
                $packageReference.SetAttribute("Version", $package.Version)
                $group=$_.ParentNode
                $group.AppendChild($csproj.CreateTextNode([System.Environment]::NewLine)) | Out-Null
                $group.AppendChild($csproj.CreateTextNode("    ")) | Out-Null
                $group.AppendChild($packageReference) | Out-Null
                $group.AppendChild($csproj.CreateTextNode([System.Environment]::NewLine)) | Out-Null
                $group.RemoveChild($_)
            }
            $projectPath | Remove-BlankLines
            $csproj.Save($_)
        }
    }
    
    end {
        
    }
}
