function Format-Shuffle {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [object]$Value
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $values=@()
    }
    
    process {
        $values+=$Value
    }
    end {
        $values| Sort-Object {Get-Random}
    }
}