function Clear-ProjectDirectories {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [string[]]$path=(Get-Location),
        [string[]]$include=@("bin","obj",".vs","_Resharper","packages","*.bak","*.log")
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Get-ChildItem $path -Recurse -Include $include|Remove-Item -Force -Recurse        
    }
    
    end {
        
    }
}