function Get-ProjectAssemblyMetadata {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet", "#dotnetcore"))]
    param (
        [parameter(Mandatory)]
        [System.IO.FileInfo]$AssemblyInfo,
        [parameter(Mandatory)]
        [string]$Key
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin        
    }
    
    process {
        $regex = [regex] "(?is)AssemblyMetadata\(`"$key`",`(?<value>[^\)]*)"
        Get-Content $AssemblyInfo.FullName |ForEach-Object{
            $line=$_
            $result=$regex.Match($_).Groups['value'].Value;
            if ($result){
                $result.Trim('"')
            }
        }
        
    }
    
    end {
        
    }
}