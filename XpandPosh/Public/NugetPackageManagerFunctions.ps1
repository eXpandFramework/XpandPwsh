function Update-ProjectPackage {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="VSPkgManager")]
        [System.__ComObject]$Project, 
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="Path")]
        [string]$Path,
        [string]$Filter, 
        [string]$Version
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -eq "VSPkgManager"){
            $Path=(Get-Item $Project).DirectoryName
        }
    }
    
    process {
        Get-ChildItem $Path packages.config -Recurse|ForEach-Object{
            $packageItem=$_
            [xml]$config=Get-Content $packageItem.FullName
            Write-Verbose "Checking $($packageItem.FullName)"
            $config.packages.package|where{!$filter -bor $_.Id -like "*$filter*"}|ForEach-Object{
                Write-Verbose "Updating $($_.Id)"
                Update-NugetPackages -sourcePath ($packageItem.DirectoryName) -filter $_.Id 
            }
        }
    }
    
    end {
    }
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
    Uninstall-ProjectAllPackages Xpand.XAF.
}
