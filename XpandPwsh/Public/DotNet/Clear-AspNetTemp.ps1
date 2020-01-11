function Clear-AspNetTemp {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        net stop w3svc
        Get-Process iisexpress.exe -ErrorAction SilentlyContinue|Stop-Process
        Get-ChildItem "C:\Windows\Microsoft.NET\Framework*\v*\Temporary ASP.NET Files" -Recurse| Remove-Item -Recurse -Force
        net start w3svc
    }
    
    end {
        
    }
}