function Install-NugetPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Id,
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Version,
        [parameter()][string]$OutputDirectory=(Get-NugetInstallationFolder),
        [parameter()]
        [string[]]$Source=(Get-PackageSource).Name

    )
    
    begin {
        $Source=ConvertTo-PackageSourceLocation $Source
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        Push-Location $env:TEMP
        Use-NugetConfig -Sources $Source -ScriptBlock {
            Get-NugetPackage $Id -Versions $Version  -Source $Source  -OutputFolder $OutputDirectory
        }
        Pop-Location
    }
    
    end {
        
    }
}
