function Add-AssemblyBindindRedirect {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id,
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Version,
        [string]$Culture="neutral",
        [string]$PublicToken
    )
    
    begin {
        $xml=@()
    }
    
    process {
        $binding=$config.configuration.runtime.assemblyBinding.dependentAssembly|Where-Object{$_.assemblyIdentity.name -eq $id}
        if ($binding){
            $binding.bindingRedirect.oldVersion="0.0.0.0-$Version"
            $binding.bindingRedirect.newVersion=$Version
        }
        else{
            $xml += @"
`n
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
        <dependentAssembly>
            <assemblyIdentity name="$id" publicKeyToken="$PublicToken" culture="$culture" />
            <bindingRedirect oldVersion="0.0.0.0-$Version" newVersion="$Version" />
        </dependentAssembly>
    </assemblyBinding>
"@
            
        }
    }
    
    end {
        $config.SelectSingleNode("//runtime").InnerXml+=$xml
        $config.Save($configFile)
    }
}