function Remove-XmlElement {
    [CmdletBinding(DefaultParameterSetName="Parent")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,ValueFromPipeline,Position=0)]
        [System.Xml.XmlElement]$Parent,
        [parameter(Mandatory,Position=1)]
        [string[]]$ElementName
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $childNodes=@()
    }
    
    process {
        $childNodes+=$Parent.ChildNodes|Where-Object{$_.name -in $ElementName}
        
    }
    
    end {
        $childNodes|ForEach-Object{
            $_.ParentNode.RemoveChild($_)
        }
    }
}