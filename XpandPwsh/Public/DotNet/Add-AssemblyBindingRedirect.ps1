function Add-AssemblyBindingRedirect {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id,
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Version,
        [string]$Path=".",
        [string]$Culture="neutral",
        [string]$PublicToken
    )
    
    begin {
        $xml=@()
    }
    
    process {
        $config=Get-ChildItem $Path *.config|ForEach-Object{
            [xml](Get-Content $_)
        }
        if (!$config){
            $defaultConfig=@"
            <configuration>
                <runtime>
                </runtime>
            </configuration>
"@

            $configPath="$((Get-Item $Path).DirectoryName)\app.config"
            Set-Content $configPath
            [xml]$config=Get-Content $configPath $defaultConfig
        }
        $config|ForEach-Object{
            $binding=$_.configuration.runtime.assemblyBinding.dependentAssembly|Where-Object{$_.assemblyIdentity.name -eq $id}
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
        
    }
    
    end {
        $config.SelectSingleNode("//runtime").InnerXml+=$xml
        $config.Save($configFile)
    }
}