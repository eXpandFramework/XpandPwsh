function Uninstall-ProjectAllPackages($packageFilter) {
    
    while ((Get-Project | Get-Package | Where-Object {
                $_.id.Contains($packageFilter)
            } ).Length -gt 0) { 
        Get-Project | Get-Package | Where-Object {
            $_.id.Contains($packageFilter)
        } | Uninstall-Package 
    }
    
}