function Remove-BlankLines {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        $Path
    )
    
    begin {
    }
    
    process {
        (Get-Content $Path) | Where-Object {$_.trim() -ne "" } | set-content $Path
    }
    
    end {
    }
}