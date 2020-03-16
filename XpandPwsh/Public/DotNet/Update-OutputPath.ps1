function Update-OutputPath {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory)]
        [xml]$CSProj,
        [parameter(Mandatory)]
        [string]$ProjectPath,
        [parameter(Mandatory)]
        [string]$OutputPath
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $path = Get-RelativePath $projectPath $outputPath
        $outputPathSuffix=$CSProj.project.PropertyGroup.OutputPathSuffix
        $path+="\$outputPathSuffix"
        Update-ProjectProperty $CSProj OutputPath $path.Trim("\").Trim()
        $projectDir=$((Get-Item $ProjectPath).DirectoryName)
        if ((!(Test-ProjectSdk $CSProj)) -and (Test-Path "$projectDir\web.config") -and $OutputPath -ne "\bin" -and $OutputPath -ne "bin"){
            $linkText='if exist "$(MSBuildProjectDirectory)\bin" rmdir "$(MSBuildProjectDirectory)\bin"`r`nmklink /J "$(MSBuildProjectDirectory)\bin" "$(MSBuildProjectDirectory)\$(OutputPath)"'
            $postBuildEvent=$CSProj.project.PropertyGroup.PostBuildEvent|Where-Object{$_}
            if (($postBuildEvent|Where-Object{
                $_ -notlike "*$linkText*"
            })){
                Add-ProjectBuildEvent PostBuildEvent $CSProj -InnerText $linkText -Append
            }
        }
        
    }
    
    end {
    }
}