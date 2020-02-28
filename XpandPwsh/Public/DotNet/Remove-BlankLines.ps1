function Remove-BlankLines {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
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