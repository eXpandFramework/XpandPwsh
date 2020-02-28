
function Clear-DotNetSdkFallBackFolder {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#nuget"))]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $path=(Get-DotNetCoreVersion|Select-Object -First 1).path
        Get-ChildItem "$path\NugetFallbackFolder" |ForEach-Object{
            Remove-Item $_.FullName -Force -Recurse
        }        
    }
    
    end {
        
    }
}

