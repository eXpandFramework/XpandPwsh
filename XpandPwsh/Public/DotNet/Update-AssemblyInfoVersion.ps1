
function Update-AssemblyInfoVersion {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(mandatory)]$version, $path
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        if (!$path) {
            $path = "."
        }
        Get-ChildItem -path $path -filter "*AssemblyInfo.cs" -Recurse|ForEach-Object {
            $c = Get-Content $_.FullName
            $result = $c -creplace 'Version\("([^"]*)', "Version(""$version"
            Set-Content $_.FullName $result
        }        
    }
    
    end {
        
    }
}