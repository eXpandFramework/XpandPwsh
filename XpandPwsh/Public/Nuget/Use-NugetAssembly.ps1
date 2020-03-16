function Use-NugetAssembly {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$packageName,
        [ValidateSet("NETFramework","NETStandard","NETCoreApp")]
        [string[]]$framework="NETFramework",
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [string]$Source = (Get-PackageFeed -Nuget),
        [version]$Version
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $package=Get-NugetPackage -name $packageName -OutputFolder $OutputFolder -Source $Source -Versions $Version
        $package | where-object { $_.DotnetFramework -like "*$framework*" } | ForEach-Object {
            $v = [version]$_.Version
            $version = "$($v.Major).$($v.Minor).$($v.Build)"
            $fullName = "$OutputFolder\$packagename\$version\$($_.File)"
            Mount-Assembly $fullName
        }
    }
    
    end {
    }
}