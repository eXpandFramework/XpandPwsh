function Remove-XmlElement {
    [CmdletBinding(DefaultParameterSetName="Parent")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,ValueFromPipeline,Position=0)]
        [System.Xml.XmlElement]$Element
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $Element.ParentNode.RemoveChild($Element)
    }
    
    end {
        
    }
}