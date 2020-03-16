function Remove-PackageReference {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$ProjectFile,
        [parameter(Mandatory)]
        [string]$IdMatch
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Push-Location $ProjectFile.DirectoryName
        [xml]$csproj = Get-XmlContent $ProjectFile.FullName
        $csproj.Project.ItemGroup.packageReference | ForEach-Object {
            if ($_.include -match $IdMatch ) {
                $_.ParentNode.RemoveChild($_)    
            }
        }
        $csproj | Save-Xml $ProjectFile.FullName|Out-Null
        Pop-Location
    }
    
    end {
        
    }
}
