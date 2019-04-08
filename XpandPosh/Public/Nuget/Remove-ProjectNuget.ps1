function Remove-ProjectNuget{
    param(
        [parameter(Mandatory)]
        [string]$id,
        [string]$projectPath=(Get-Location),
        [parameter(Mandatory)]
        [string]$nugetAssembliesBin
    )
    Get-ChildItem $projectPath *.csproj -Recurse | ForEach-Object { 
        [xml]$project=Get-XmlContent $_.FullName
        $project.Project.ItemGroup.Reference|Where-Object{$_.Include -match "$id"}|ForEach-Object{
            $fileName=[System.IO.Path]::GetFileName($_.Hintpath)
            $hintPath="$nugetAssembliesBin\$fileName"
            if (!(Test-Path $hintPath)){
                throw "HintPath not found: $hintPath"
            }
            $_.Hintpath= $hintPath
        }

        $project.Save($_.FullName)
    } 
    push-location $projectPath
    Clear-ProjectDirectories 
    pop-location
}
