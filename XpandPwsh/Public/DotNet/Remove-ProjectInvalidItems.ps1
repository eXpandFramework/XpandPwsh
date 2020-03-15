function Remove-ProjectInvalidItems {
    [CmdletBinding()]
    [CmdLetTag(("#visualstudio","#msbuild"))]
    param (
        [string]$ProjectFile,
        [parameter()]
        $MSBuildProject,
        [ValidateSet("Imports","Analyzer")]
        [string[]]$ItemType=@("Imports","Anazlyzers")
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        if (!$MSBuildProject){
            $msBuildProject=(Read-MSBuildProject $ProjectFile)
        }
        [xml]$csproj = Get-XmlContent $ProjectFile
        if ("Imports" -in $ItemType ){
            $importedProjects=$MSBuildProject.Imports.ImportingElement.Project
            $import=$csproj.Project.Import
            if ($import){
                $import|Where-Object{$_.Project -notin $importedProjects}|ForEach-Object{
                    $_.ParentNode.RemoveChild($_)
                }
            }
        }
        if ("Anazlyzers" -in $ItemType ){
            $analyzers=$MSBuildProject.Items|Where-Object{$_.ItemType -eq "Analyzer"}
            $rootedAnalyzers=@($analyzers|Where-Object{([System.IO.Path]::IsPathRooted($_.EvaluatedInclude))})
            Push-Location (Get-Item $ProjectFile).DirectoryName
            @($analyzers|Where-Object{!([System.IO.Path]::IsPathRooted($_.EvaluatedInclude))}|Where-Object{
                !(Resolve-Path $_.EvaluatedInclude -Relative -ErrorAction SilentlyContinue)
            })+$rootedAnalyzers|ForEach-Object{
                $item=$_
                $csproj.Project.ItemGroup.Analyzer|Where-Object{$_.Include -eq $item.UnevaluatedInclude}|ForEach-Object{
                    $_.ParentNode.RemoveChild($_)
                }
            }
            Pop-Location
        }
        
        $csproj | Save-Xml $ProjectFile |Out-Null
    }
    
    end {
        
    }
}
