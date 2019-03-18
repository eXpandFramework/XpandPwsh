function Remove-ProjectNuget{
    param(
        [parameter(Mandatory)]
        [string]$id,
        [string]$path=(Get-Location)
    )
    Get-ChildItem $path *.csproj -Recurse | ForEach-Object { 
        $fiLeName=$_.FullName 
        [xml]$project=Get-Content $_.FullName 
        $project.Project.ItemGroup.Reference|Where-Object{$_.Include -like "*$id*"}|ForEach-Object{
            if ($_.SpecificVersion){
                $_.SpecificVersion="False"
            }
            if($_.HintPath){
                $_.ChildNodes|ForEach-Object{
                    $_.ParentNode.RemoveChild($_)
                }
            }
        }
        $project.Save($fiLeName)
    } 
    push-location $path
    Clear-ProjectDirectories 
    pop-location
}
