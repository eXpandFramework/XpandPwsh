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
        Update-ProjectProperty $CSProj OutputPath $path
    }
    
    end {
    }
}