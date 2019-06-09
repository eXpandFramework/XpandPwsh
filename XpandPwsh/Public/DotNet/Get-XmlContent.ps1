function Get-XmlContent {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$FilePath
    )
    
    begin {
    }
    
    process {
        ( Select-Xml -Path $FilePath -XPath / ).Node
    }
    
    end {
    }
}