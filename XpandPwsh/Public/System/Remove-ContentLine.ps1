function Remove-ContentLine {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Path,
        [string]$Match=".*"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Set-Content -Path $Path.FullName -Value (get-content -Path $Path.FullName | Select-String -Pattern $Match -NotMatch)
    }
    
    end {
        
    }
}