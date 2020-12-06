function Read-MSBuildSolutionFile {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#msbuild"))]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string]$Path
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        Use-MSBuildFramework|Out-Null
    }
    
    process {
        [Microsoft.Build.Construction.SolutionFile]::Parse($Path)
    }
    
    end {
        
    }
}