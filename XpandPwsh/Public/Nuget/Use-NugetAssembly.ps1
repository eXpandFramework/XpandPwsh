function Use-NugetAssembly {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$packageName,
        [string]$framework = "*",
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [string]$Source = (Get-PackageFeed -Nuget),
        [version]$Version
    )
    
    begin {
    }
    
    process {
        $package=Get-NugetPackage -name $packageName -OutputFolder $OutputFolder -Source $Source -Versions $Version
        $package | where-object { $_.DotnetFramework -match $framework } | ForEach-Object {
            $v = [version]$_.Version
            $version = "$($v.Major).$($v.Minor).$($v.Build)"
            $fullName = "$OutputFolder\$packagename\$version\$($_.File)"
            Mount-Assembly $fullName
        }
    }
    
    end {
    }
}