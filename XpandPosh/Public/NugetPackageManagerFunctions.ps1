function Update-PackageInProjects($projectWildCard, $packageId, $version) {
    Get-Project $projectWildCard | ForEach-Object {Update-Package  -Id $packageId -ProjectName $_.ProjectName -Version $version}
}

function Install-AllProjects($packageName) {
    Get-Project -All | Install-Package $packageName
}

function Uninstall-ProjectAllPackages($packageFilter) {
    
    while((Get-Project | Get-Package | Where-Object  {
        $_.id.Contains($packageFilter)
    } ).Length -gt 0) { 
        Get-Project | Get-Package | Where-Object  {
            $_.id.Contains($packageFilter)
        } | Uninstall-Package 
    }
    
}
function Uninstall-ProjectXAFPackages {
    Uninstall-ProjectAllPackages DevExpress.XAF.
}
