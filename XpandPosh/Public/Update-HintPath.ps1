function Update-HintPath{
    param(
        [parameter(Mandatory)]
        [string]$SourcesPath,
        [parameter(Mandatory)]
        [string]$OutputPath,
        [string]$filter="DevExpress*"

    )
    Get-ChildItem $sourcesPath "*.csproj" -Recurse|ForEach-Object {
        $projectPath = $_.FullName
        Write-Host "Checking DX references $projectPath"
        $projectDir = (Get-Item $projectPath).DirectoryName
        [xml]$csproj = Get-Content $projectPath
        $csproj.Project.ItemGroup.Reference|Where-Object {$_.Include -like $filter}|
            Where-Object {!"$($_.Include)".Contains(".DXCore.")}|ForEach-Object {
            $reference = $_
            if (!$reference.Hintpath) {
                $reference.AppendChild($reference.OwnerDocument.CreateElement("HintPath", $csproj.DocumentElement.NamespaceURI))|out-null
            }            
            $hintPath = Get-RelativePath $projectPath $outputPath
            $reference.HintPath = "$hintPath\$($reference.Include).dll"
            if (!$(Test-path $("$projectDir\$hintPath"))) {
                throw "File not found $($reference.HintPath)"
            }
            $csproj.Save($projectPath)
        }
    }
}