function Get-XpandPackages {
    [CmdletBinding()]
    param (
        [parameter()]
        [ValidateSet("Release", "Lab")]
        $Source,
        [ValidateSet("All", "eXpand", "XAF")]
        $PackageType = "All"
    )
    
    begin {
    }
    
    process {
        if ($PackageType -eq "All") {
            $Filter = "*"
        }
        elseif ($PackageType -eq "eXpand") {
            $Filter = "eXpand*"
        }
        elseif ($PackageType -eq "XAF") {
            $Filter = "Xpand.XAF.Modules*"
        }
        try {
            $c=New-Object System.Net.WebClient
            ($c.DownloadString("https://xpandnugetstats.azurewebsites.net/api/totals/packages?packagesource=xpand")|ConvertFrom-Json|ForEach-Object{
                $_|ForEach-Object{
                    [PSCustomObject]@{
                        Id = $_.Id
                        Version=$_.Version
                        Source="Lab"
                    }
                }
            })+($c.DownloadString("https://xpandnugetstats.azurewebsites.net/api/totals/packages?packagesource=Nuget")|ConvertFrom-Json|ForEach-Object{
                $_|ForEach-Object{
                    [PSCustomObject]@{
                        Id = $_.Id
                        Version=$_.Version
                        Source="Release"
                    }
                }
            })|Where-Object{$_.id -like $Filter -and $_.Source -eq $Source}
            $c.Dispose()
        }
        catch {
            $nuget = Get-NugetPath
            if (($Source -eq "Release") -or !$Source) {
                $query = & $nuget List author:eXpandFramework -source (Get-PackageFeed -Nuget)
            $_
            }
            else {
                $query = & $nuget List -source (Get-PackageFeed -Xpand)
            }
            $filter.split(";") | ForEach-Object {
                $f = $_
                $query | Where-Object { $_ -like $f } | ConvertTo-PackageObject
            }
        }
        
    }
    
    end {
    }
}
