function Clear-AspNetTemp {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#aspnet"))]
    param (
        [Switch]$DonotStopIIS,
        [Switch]$DonotStopIISExpress
    )
    
    begin {
        
    }
    
    process {
        if (!$DonotStopIIS){
            net stop w3svc
        }
        if (!$DonotStopIISExpress){
            $iisExpress=Get-Process iisexpress.exe -ErrorAction SilentlyContinue
            if ($iisExpress){
                "Stoping iisexpress..."
                $iisExpress|Stop-Process -Force
            }
            
        }
        
        Get-Process iisexpress.exe -ErrorAction SilentlyContinue|Stop-Process
        Get-ChildItem "C:\Windows\Microsoft.NET\Framework*\v*\Temporary ASP.NET Files" -Recurse| Remove-Item -Recurse -Force
        if (!$DonotStopIIS){
            net start w3svc
        }
    }
    
    end {
        
    }
}