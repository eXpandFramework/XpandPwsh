function Out-Verbose {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        $VerboseInput,
        [Switch]$PassThrough
    )
    
    begin {
        $items=@()
    }
    
    process {
        $items+=$VerboseInput
    }
    
    end {
        $items | Out-String -Stream|Where-Object{$_} | Write-Verbose -Verbose
    }
}