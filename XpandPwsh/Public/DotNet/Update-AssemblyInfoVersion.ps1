
function Update-AssemblyInfoVersion {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(mandatory)]$version, 
        [parameter(ValueFromPipeline)][string]$path
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
        Get-ChildItem -path $path -filter "*AssemblyInfoVersion.cs" -Recurse|ForEach-Object {
            $c = Get-Content $_.FullName -raw
            $regex = [regex] '(?s)Version = "([^"]*)'
            $result = $regex.Replace($c, "Version = `"$version")
            Set-Content $_.FullName $result -Force
        }        
    }
    
    end {
        
    }
}