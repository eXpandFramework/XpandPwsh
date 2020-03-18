function Add-AssemblyBindingRedirect {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [ArgumentCompleter({
            [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            
            (Find-Nugetpackage -name $WordToComplete).Id
        })]
        [string]$Id,
        [parameter(ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Version,
        [parameter(Mandatory)]
        [System.IO.FileInfo]$ConfigFile = (Get-Location),
        [string]$Culture = "neutral",
        [parameter(Mandatory)]
        [string]$PublicToken
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $xml = @()
        [xml]$config = Get-Content $configFile
        if (!$config.SelectSingleNode("//runtime")){
            Add-XmlElement -Owner $config -elementName "runtime" -parent "configuration" 
            $Config|Save-Xml $ConfigFile
        }
    }
    
    process {
        
        $binding = $config.configuration.runtime.assemblyBinding.dependentAssembly | Where-Object { $_.assemblyIdentity.name -eq $id }
        if ($binding) {
            $binding.assemblyIdentity.name=$Id
            $binding.bindingRedirect.oldVersion = "0.0.0.0-$Version"
            $binding.bindingRedirect.newVersion = $Version
        }
        else {
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
        $config.SelectSingleNode("//runtime").InnerXml += $xml
        $config|Save-Xml $configFile|Out-Null
    }
}