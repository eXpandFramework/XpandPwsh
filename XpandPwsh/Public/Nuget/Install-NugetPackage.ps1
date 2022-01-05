function Install-NugetPackage {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Id,
        # [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Version,
        [parameter()][string]$OutputDirectory=(Get-NugetInstallationFolder),
        [parameter()]
        [string[]]$Source=(Get-PackageSource).Name,
        [switch]$Prerelease

    )
    
    begin {
        $Source=ConvertTo-PackageSourceLocation $Source
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        Push-Location $env:TEMP
        Use-NugetConfig -Sources $Source -ScriptBlock {
            $p=@($Id, "-OutputDirectory",$OutputDirectory )
            if ($Version){
                $p+=@("-Version", $Version)
            }
            if ($Prerelease){
                $p+="-Prerelease"
            }
            & (Get-NugetPath) install @p
        }
        Pop-Location
    }
    
    end {
        
    }
}
