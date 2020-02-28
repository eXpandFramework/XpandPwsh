function Get-AssemblyPublicKeyToken {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$Assembly
    )
    
    begin {
    }
    
    process {
        
        $asm=Mount-Assembly $Assembly.FullName
        (($asm.GetName().GetPublicKeyToken()|ForEach-Object{
            $_.ToString("x2")
        }) -join "").Trim("")
    }
    
    end {
    }
}