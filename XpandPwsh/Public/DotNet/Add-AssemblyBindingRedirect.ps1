function Add-AssemblyBindingRedirect {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter(ValueFromPipelineByPropertyName, Mandatory,ParameterSetName="Id")]
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
        [parameter(Mandatory)]
        [System.IO.FileInfo]$ConfigFile ,
        [string]$Culture = "neutral",
        [parameter(Mandatory)]
        [string]$PublicToken,
        [parameter(ValueFromPipeline,Mandatory,ParameterSetName="File")]
        [System.IO.FileInfo]$Assembly
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $xml = @()
        [xml]$config = Get-Content $configFile
        if (!$config.SelectSingleNode("//runtime")){
            Add-XmlElement -Owner $config -elementName "runtime" -parent "configuration" 
            $Config|Save-Xml $ConfigFile
        }
        if ($PSCmdlet.ParameterSetName -eq "File" -and !$Version){
            $version=Get-AssemblyVersion $Assembly
        }
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "File"){
            try {
                $data=Use-Object($asm=Read-AssemblyDefinition $Assembly.FullName){
                    if ($asm.Name.publicKeyToken){
                        [PSCustomObject]@{
                            Token = Get-AssemblyPublicKeyToken -bytes $asm.Name.publicKeyToken
                            Version=$asm|Get-AssemblyVersion 
                        }
                    }
                }
                $id=$Assembly.BaseName       
                $PublicToken=$data.Token
                if (!$Version){
                    $Version=$data.Version
                }
                
            }
            catch {
                Write-Warning $Assembly.BaseName
                Write-Error $_ -ErrorAction Continue
                return
            }
        }
        if ($PublicToken){
            $binding = $config.configuration.runtime.assemblyBinding.dependentAssembly | Where-Object { $_.assemblyIdentity.name -eq $id }
            if ($binding) {
                $binding.assemblyIdentity.name=$id
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
    }
    end {
        $config.SelectSingleNode("//runtime").InnerXml += $xml
        $config|Save-Xml $configFile.FullName|Out-Null
    }
}