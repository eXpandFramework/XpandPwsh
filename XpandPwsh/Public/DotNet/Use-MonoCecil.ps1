function Use-MonoCecil {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore","#monocecil"))]
    param (
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [switch]$All
    )
    
    begin {
    }
    
    process {
        $assemblies = 1
        if ($All) {
            $assemblies = 3
        }
        $mono = Get-Assembly "Mono.Cecil"
        if (!$mono) {
            $mono = Use-NugetAssembly Mono.Cecil NETFramework $OutputFolder | Select-Object -First $assemblies
        }
        $mono
        
    }
    
    end {
    }
}