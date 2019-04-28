function Uninstall-ProjectAllPackages($packageFilter) {
    
    while ((Get-Project | Get-Package | Where-Object {
                $_.id -like $packageFilter
            } ).Length -gt 0) { 
        Get-Project | Get-Package | Where-Object {
            $_.id -like $packageFilter
        } | Uninstall-Package 
    }
}