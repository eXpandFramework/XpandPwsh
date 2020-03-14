function Write-PSCmdLetBegin {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        $CmdLet
    )
    
    begin {
        
    }
    
    process {
        $cmdletName="$($Cmdlet.CommandRuntime)"
        Write-HostFormatted -object $cmdletName -Stream Verbose -Section -ForegroundColor Blue
    }
    
    end {
        
    }
}