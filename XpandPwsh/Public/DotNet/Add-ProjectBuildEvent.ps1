function Add-ProjectBuildEvent {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("PostBuildEvent","PreBuildEvent")]
        [string]$EventName,
        [parameter(Mandatory)]
        [xml]$Project,
        [parameter(Mandatory)]
        [string]$InnerText,
        [switch]$Append
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        Invoke-Script{
            $eventNode=$Project.Project.PropertyGroup.$EventName|Where-Object{$_}
            if (!$eventNode){
                $container=Add-XmlElement -Owner $Project -ElementName PropertyGroup -Parent Project 
                $eventNode=Add-XmlElement -Owner $Project -ElementName $EventName -Parent PropertyGroup -InnerText $InnerText
                $eventNode.ParentNode.RemoveChild($eventNode)
                $container.AppendChild($eventNode)
            }
            else{
                $ns = New-Object System.Xml.XmlNamespaceManager($Project.NameTable)
                $nsUri=$Project.DocumentElement.NamespaceURI
                $ns.AddNamespace("ns", $nsUri)
                $eventNode=$Project.SelectSingleNode("//ns:$EventName", $ns)
                if ($Append){
                    $InnerText="$($eventNode.InnerText)`r`n$InnerText"
                }
                $eventNode.InnerText=$InnerText
            }
        }
    }
    end {
        
    }
}