function Save-Xml {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [xml]$Owner,
        [parameter(Mandatory,Position =2)]
        [string]$Path
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $Owner.Save($Path)|Out-Null
        Get-Variable Path|Out-Variable 
        Format-Xml -Path $Path|Out-Null
    }
    
    end {
        
    }
}