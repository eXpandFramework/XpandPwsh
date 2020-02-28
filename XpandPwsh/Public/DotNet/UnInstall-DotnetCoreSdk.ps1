function UnInstall-DotnetCoreSdk {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $app = Get-WmiObject -Class Win32_Product | Where-Object { 
            $_.Name -match "Microsoft .NET Core SDK" 
        }
        
        Write-Host $app.Name 
        Write-Host $app.IdentifyingNumber
        Push-Location $env:SYSTEMROOT\System32
        
        $app.identifyingnumber |ForEach-Object { Start-Process msiexec -wait -ArgumentList "/x $_" }
        
        Pop-Location
    }
    
    end {
        
    }
}