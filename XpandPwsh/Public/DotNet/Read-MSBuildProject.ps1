function Read-MSBuildProject {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#msbuild"))]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string]$ProjectPath
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Use-MSBuildFramework|Out-Null
    }
    
    process {
        Set-Content $ProjectPath ((Get-Content $projectPath -Raw).Replace('$(MSBuildBinPath)','$(MSBuildToolsPath)'))

        $msbuildPath=(Get-Item (Get-MsBuildPath)).DirectoryName
        $dict=New-GenericObject -PredifinedType StringDictionary
        $extensionsPath="$msbuildPath\..\.."
        $sdkPath="$extensionsPath\sdk"
        $dict.Add("MSBuildExtensionsPath", $extensionsPath)
        $dict.Add("MSBuildSDKsPath", $sdkPath)
        $dict.Add("MSBuildExtensionsPath32", $extensionsPath )
        $dict.Add("RoslynTargetsPath", "$msbuildPath\Roslyn" )
        [xml]$content=Get-Content $ProjectPath 
        if (Test-ProjectSdk $content){
            $sdk=Get-DotNetCoreVersion SDK|Select-Object -Last 1
            $dict["MSBuildSDKsPath"]="$($sdk.Path)\$($sdk.Version)\Sdks\"
            $env:MSBuildExtensionsPath=$extensionsPath
            $env:MSBuildSDKsPath=$dict["MSBuildSDKsPath"]
        }

        $projectCollection=[Microsoft.Build.Evaluation.ProjectCollection]::new($dict)
        $projectCollection.AddToolset(([Microsoft.Build.Evaluation.Toolset]::new("Current",$msbuildPath,$projectCollection,[string]::Empty)))
        $projectCollection.DefaultToolsVersion="Current"
        $projectCollection.LoadProject($projectPath)        
    }
    
    end {
        
    }
}