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
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Version,
        [string]$Path = (Get-Location),
        [string]$Culture = "neutral",
        [string]$PublicToken
    )
    
    begin {
        $xml = @()
        $configFile = Get-ChildItem $Path *.config | Select-Object -First 1
        if (!$configFile) {
            $defaultConfig = @"
            <configuration>
                <runtime>
                </runtime>
            </configuration>
"@

            $configFile = "$((Get-Item $Path).FullName)\app.config"
            Set-Content $configFile $defaultConfig
        }
        [xml]$config = Get-Content $configFile
        if (!$config.SelectSingleNode("//runtime")){
            Add-XmlElement $config "runtime" "configuration"
            $config.Save($configFile)
        }
        if (!$Version){
            $packages=Get-PackageReference ((Get-ChildItem $Path "*.*proj").FullName)
            $Version=($packages|Where-Object{$_.Include -eq $Id}).Version
            if (!$Version){
                throw "Cannot find $id version"
            }
        }
        if (!$PublicToken){
            [xml]$proj=Get-Content (((Get-ChildItem $Path "*.*proj").FullName))
            $outputPath="$Path\$($proj.Project.PropertyGroup.OutputPath|Select-Object -First 1)"
            $assemblypath=[System.IO.Path]::GetFullPath("$outputPath\$id.dll")
            $PublicToken=Get-AssemblyPublicKeyToken $assemblypath
            
        }
        
        
    }
    
    process {
        $binding = $config.configuration.runtime.assemblyBinding.dependentAssembly | Where-Object { $_.assemblyIdentity.name -eq $id }
        if ($binding) {
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
        $config.Save($configFile)
    }
}