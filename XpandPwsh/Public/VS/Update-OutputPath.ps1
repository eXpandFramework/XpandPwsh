function Update-OutputPath {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [parameter(Mandatory)]
        [string]$ProjectPath,
        [parameter(Mandatory)]
        [string]$OutputPath
    )
    
    begin {
    }
    
    process {
        $path = Get-RelativePath $projectPath $outputPath
        $outputPathSuffix=$CSProj.project.PropertyGroup.OutputPathSuffix
        $path+="\$outputPathSuffix"
        Update-ProjectProperty $CSProj OutputPath $path.Trim("\").Trim()
    }
    
    end {
    }
}