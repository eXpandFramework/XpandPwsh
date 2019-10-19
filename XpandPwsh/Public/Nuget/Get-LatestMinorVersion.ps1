function Get-LatestMinorVersion {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $Name,
        $Source=(Get-PackageFeed -Nuget)
    )
    
    begin {
    }
    
    process {
        Get-NugetPackageSearchMetadata -Name $Name -AllVersions -Source $Source | ForEach-Object {
            $v = $_.Identity.Version.Version
            [PSCustomObject]@{
                Version = $v
                Minor   = "$($v.Major).$($v.Minor)"
            }
        } | Group-Object -Property Minor | ForEach-Object {
            $_.Group | Select-Object -First 1 -ExpandProperty Version
        } | Sort-Object -Descending | Select-Object -First 6
    }
    
    end {
    }
}