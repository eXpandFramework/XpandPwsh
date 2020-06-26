function Get-XmlContent {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [System.IO.FileInfo]$FilePath
    )
    
    begin {
    }
    
    process {
        $ns=([xml](Get-Content $FilePath.fullname)).DocumentElement.NamespaceURI
        ( Select-Xml -Path $FilePath.fullname -XPath / -Namespace @{mse=$ns}).Node
    }
    
    end {
    }
}