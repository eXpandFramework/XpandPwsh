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
        $items | Out-String -Stream | Write-Verbose -Verbose
    }
}