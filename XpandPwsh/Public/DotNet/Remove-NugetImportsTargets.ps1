function Remove-NugetImportsTargets {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$ProjectFile
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        [xml]$csproj = Get-XmlContent $Projectfile.FullName
        $csproj.Project.Import | Where-Object { $_.Project -like "*\Nuget.targets" } | ForEach-Object {
            $_.ParentNode.RemoveChild($_)
        }
        $csproj.Project.Target | Where-Object { $_.Name -eq "EnsureNuGetPackageBuildImports" } | ForEach-Object {
            $_.ParentNode.RemoveChild($_)
        }
        $csproj | Save-Xml $Projectfile.FullName
    }
    
    end {
    }
}