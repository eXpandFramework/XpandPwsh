function Use-NugetAssembly {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$packageName,
        [ValidateSet("NETFramework","NETStandard",".NETFramework,Version=v5.0",".NETFramework,Version=v6.0")]
        [string[]]$Framework,
        [string]$OutputFolder = "$env:TEMP\$packageName",
        [string]$Source = (Get-PackageFeed -Nuget),
        [version]$Version
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $package=Get-NugetPackage -name $packageName -OutputFolder $OutputFolder -Source $Source -Versions $Version
        $frameworks=$package.DotnetFramework
        $frameworkFilter="*$Framework*"
        if ($frameworks.count -gt 1 -and !$Framework){
            throw "Multiple frameworks found ($frameworks) for $packageName. Please use the Framework parameter."
        }
        elseif ($frameworks.count -eq 1 -and !$Framework){
            $frameworkFilter="*"
        }
        $package | where-object { $_.DotnetFramework -like $frameworkFilter } | ForEach-Object {
            $v = [version]$_.Version
            $version = "$($v.Major).$($v.Minor).$($v.Build)"
            $fullName = "$OutputFolder\$packagename\$version\$($_.File)"
            Mount-Assembly $fullName
        }
    }
    
    end {
    }
}