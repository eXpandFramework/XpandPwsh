
function Invoke-PaketSimplify {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [string]$Path = "."
    )
    
    begin {
        
    }
    
    process {
        Get-PaketDependenciesPath|ForEach-Object{
            Write-Host "Paket Simplify $($_.FullName)" -f Blue
            Push-Location $_.directoryName
            Invoke-Script {dotnet paket simplify}
            Pop-Location
        } 
    }
    
    end {
        
    }
}