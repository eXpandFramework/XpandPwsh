function Use-MonoCecil {
    [CmdletBinding()]
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
        $mono = Use-NugetAssembly Mono.Cecil *v4.0 $OutputFolder | Select-Object -First $assemblies
        $mono
        
    }
    
    end {
    }
}