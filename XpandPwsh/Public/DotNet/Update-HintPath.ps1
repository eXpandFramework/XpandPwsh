
function Update-HintPath {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet", "#dotnetcore"))]
    param(
        [parameter(Mandatory)]
        [string]$SourcesPath,
        [parameter(Mandatory)]
        [string]$OutputPath,
        [parameter(Mandatory)]
        [string[]]$Include,
        [parameter()]
        [string[]]$Exclude,
        [System.IO.FileInfo[]]$Projects=(Get-ChildItem $sourcesPath "*.csproj" -Recurse)

    )
    
    
    begin {
        
    }
    
    process {
        $Projects | ForEach-Object {
            $projectPath = $_.FullName
            $projectDir = (Get-Item $projectPath).DirectoryName
            [xml]$csproj = Get-Content $projectPath
            $csproj.Project.ItemGroup.Reference | Where-Object {
                $ref = $_.Include
                if ($Include | Where-Object { $ref -like $_ } | Select-Object -First 1) {
                    !($Exclude | Where-Object { $ref -like $_ } | Select-Object -first 1)
                }
            } | ForEach-Object {
                if (!$_.Hintpath) {
                    $_.AppendChild($_.OwnerDocument.CreateElement("HintPath", $csproj.DocumentElement.NamespaceURI)) | Out-Null
                }            
                $reference = $_.Include
                $hintPath = Get-RelativePath $projectPath $outputPath
                $_.HintPath = "$hintPath\$reference.dll"
                if (!$(Test-Path $("$projectDir\$hintPath"))) {
                    throw "File not found $($_.HintPath)"
                }
                $csproj.Save($projectPath)
            }
        }        
    }
    
    end {
        
    }
}
