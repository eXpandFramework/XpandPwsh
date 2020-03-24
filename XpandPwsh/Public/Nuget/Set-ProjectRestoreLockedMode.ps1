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
    }
    
    end {
        
    }
}
