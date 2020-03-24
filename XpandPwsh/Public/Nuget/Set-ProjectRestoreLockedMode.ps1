function Set-ProjectRestoreLockedMode {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [xml]$Project,
        [bool]$Value=$true
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        Update-ProjectProperty  $Project RestorePackagesWithLockFile $Value
        Update-ProjectProperty  $Project RestoreLockedMode $Value
        Update-ProjectProperty  $Project NoWarn NU1603
        Update-ProjectProperty  $Project DisableImplicitNuGetFallbackFolder $Value
    }
    
    end {
        
    }
}
