function Get-AssemblyPublicKey {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$Assembly
    )
    
    begin {
    }
    
    process {
        ([System.Reflection.Assembly]::LoadFile($Assembly.FullName).GetName().GetPublicKey()|ForEach-Object{
            $_.ToString("x2")
        }) -join ""
    }
    
    end {
    }
}