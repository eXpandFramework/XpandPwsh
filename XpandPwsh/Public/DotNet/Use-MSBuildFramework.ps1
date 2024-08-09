function Use-MSBuildFramework {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#msbuild"))]
    param (
        [string]$OutputFolder = "$env:TEMP\microsoft.build",
        [version]$version="17.0.0"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Use-NugetAssembly Microsoft.build ".NETFramework,Version=v4.7.2" -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.build.framework NETStandard -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.Build.Utilities.Core NETStandard -OutputFolder $OutputFolder -version $version
        
    }
    
    end {
    }
}