[PSCustomObject]@{
    Script = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        (Get-PackageSource).Name
    }
    Parameters=@(
        [PSCustomObject]@{
            CommandName = (Get-Command "Install-NugetPackage" -Module XpandPwsh).Name
            ParameterName = "Source"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Get-NugetPackageDependencies" -Module XpandPwsh).Name
            ParameterName = "Source"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Add-PackageReference" -Module XpandPwsh).Name
            ParameterName = "Source"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Get-NugetPackageDependencies" -Module XpandPwsh).Name
            ParameterName = "Source"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Get-PackageSourceLocations" -Module XpandPwsh).Name
            ParameterName = "Name"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Get-XpandNugetPackageDependencies" -Module XpandPwsh).Name
            ParameterName = "Source"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Start-NugetRestore" -Module XpandPwsh).Name
            ParameterName = "Sources"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "Update-NugetPackage" -Module XpandPwsh).Name
            ParameterName = "Sources"
        },
        [PSCustomObject]@{
            CommandName = (Get-Command "New-XAFProject" -Module XpandPwsh).Name
            ParameterName = "Source"
        }
    )
}