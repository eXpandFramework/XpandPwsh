function Get-XPwshCommand {
    [CmdletBinding()]
    [alias("gxcm")]
    [CmdLetTag()]
    param (
        [string]$ArgumentList
    )
    
    begin {
        $dir=Get-XpandPwshDirectoryName
        Import-Module "$dir\Cmdlets\bin\XpandPwsh.Cmdlets.dll"
    }
    
    process {
        
        "XpandPwsh","XpandPwsh.CmdLets"|ForEach-Object{
            Get-Command "*$ArgumentList*" -Module $_ 
        }
    }
    
    end {
        
    }
}