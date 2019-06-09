function Use-NugetAssembly {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [string]$packageName,
        [string]$framework = "*",
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [string]$Source = (Get-PackageFeed -Nuget)
    )
    
    begin {
    }
    
    process {
        Get-NugetPackage -name $packageName -OutputFolder $OutputFolder -Source $Source | where-object { $_.DotnetFramework -like $framework } | ForEach-Object {
            $v = [version]$_.Version
            $version = "$($v.Major).$($v.Minor).$($v.Build)"
            $fullName = "$OutputFolder\$packagename\$version\$($_.File)"
            $bytes = [System.IO.File]::ReadAllBytes($fullName)
            [System.Reflection.Assembly]::Load($bytes)
        }
    }
    
    end {
    }
}