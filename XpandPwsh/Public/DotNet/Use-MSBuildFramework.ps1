function Use-MSBuildFramework {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#msbuild"))]
    param (
        [string]$OutputFolder = "$env:TEMP\microsoft.build",
        [version]$version=16.4.0
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Use-NugetAssembly Microsoft.build ".NETFramework,Version=v5.0" -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.build.framework NETStandard -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.Build.Utilities.Core NETStandard -OutputFolder $OutputFolder -version $version
        
    }
    
    end {
    }
}