function Get-DotNetTool {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [string]$id,
        [switch]$Local
    )
    
    begin {
        
    }
    
    process {
        $dntArgs=@("-g")
        if ($Local){
            $dntArgs=@("--local")
        }
        dotnet tool list @dntArgs | Select-Object -Skip 2 | ForEach-Object {
            $regex = [regex] '(?n)(?<id>[^ ]*) *(?<version>[^ ]*) *(?<commands>[^ \s]*)'
            $groups = $regex.Match($_.Trim()).Groups
        
            [PSCustomObject]@{
                Id = $groups['id'].Value
                Version = $groups['version'].Value
                Commands = $groups['commands'].Value
            }
        }|Where-Object{
            $result=$true
            if ($Id){
                $result=$_.id -match $Id
            }
            $result
        }
        
        
    }
    
    end {
        
    }
}