function Use-MSBuildFramework {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#msbuild"))]
    param (
        [string]$OutputFolder = "$env:TEMP\microsoft.build"
    )
    
    begin {
    }
    
    process {
        $version=16.4.0
        Use-NugetAssembly Microsoft.build netcore -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.build.framework netstandard -OutputFolder $OutputFolder -version $version
        Use-NugetAssembly Microsoft.Build.Utilities.Core "netstandard" -OutputFolder $OutputFolder -version $version
        
    }
    
    end {
    }
}