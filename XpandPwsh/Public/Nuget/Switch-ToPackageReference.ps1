function Switch-ToPackageReference {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [parameter()]
        [System.IO.FileInfo[]]$Packages,
        [parameter()]
        [string]$ReferenceMatch=".*",
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo[]]$ProjectFile =(Get-ChildItem *.proj)
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if ($ProjectFile.count -gt 1){
            throw "Multiple projects found in path"
        }
        $unzipFolder = "$env:TEMP\Unzipped\"
        New-Item $unzipFolder -Force -ItemType Directory |Out-Null
        $packages| ForEach-Object {
            $id = $_.BaseName
            if (!(Test-Path "$unzipFolder\$id")){
                $zipFile = "$unzipFolder\$id.zip"
                Copy-Item $_.FullName $zipFile -Force
                Expand-Archive $zipFile "$unzipFolder\$id" -Force
                Remove-Item $zipFile
            }
        }    
        $assemblies = Get-ChildItem $unzipFolder *.dll -Recurse | ConvertTo-Dictionary -KeyPropertyName BaseName -ValueSelector { $_ }
    }
    
    process {
        Invoke-Script{
            $projectDir=(get-item $ProjectFile).DirectoryName
            if (Test-Path "$projectDir\packages.config" ){
                Remove-Item "$projectDir\packages.config"
            }
            
            $addedPackages = @{
            }
            Write-HostFormatted "Switching project $($_.BaseName) " -Section -Stream Verbose
            [xml]$project = Get-XmlContent $ProjectFile.FullName
            $references = $project.project.ItemGroup.Reference|Where-Object{$_.Include -match $ReferenceMatch} | foreach-Object { 
                $id=([regex] '([^,]*)').Match($_.Include).Value 
                $assembly=$assemblies[$id]
                if (!$assembly){
                    throw "$id not found"
                }
                $item=(Get-Item $assembly).Directory
                do {
                    $packageName = $item.BaseName  
                    $item = $item.Parent
                } until ($item.BaseName -eq "UnZipped")
                $_.ParentNode.RemoveChild($_) | Out-Null
                $package=$packageName|ConvertTo-PackageObject
    
                if (!$addedPackages.ContainsKey($package.id)){
                    $addedPackages.Add($package.Id,$package.version)
                    Write-HostFormatted "Adding $($package.id) $($package.Version)" -ForegroundColor Magenta -Stream Verbose
                    Add-PackageReference -Project $project -package $package.Id -version $package.Version
                }
                $project|Save-Xml $ProjectFile.FullName|Out-Null
            }    
        }
        
    }
    
    end {
    }
}

