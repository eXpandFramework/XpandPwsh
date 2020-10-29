function Add-ContentLine {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Path,
        [parameter(Mandatory)]
        [string]$Line
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $content = get-content $Path.FullName
        if(!($content|Where-Object{$_ -eq $Line})){
            Add-Content $Path.FullName "`n$Line"
        }
    }
    
    end {
        
    }
}