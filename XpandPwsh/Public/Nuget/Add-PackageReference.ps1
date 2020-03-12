function Add-PackageReference {
    [CmdletBinding(DefaultParameterSetName="Project")]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Project")]
        [xml]$Project,
        [parameter(Mandatory,ValueFromPipeline,ParameterSetName="Project")]
        [version]$Version,
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Package,
        [parameter(ParameterSetName="Sources")]
        [string[]]$Source=(Get-PackageSourceLocations -Verbose:$false)
    )
    
    begin {
        if ($PSCmdlet.ParameterSetName -ne "Project"){
            $projects=Get-ChildItem *.*proj
            if (!$projects){
                throw "Projects not found"
            }
            if ($projects.count -gt 1){
                $projects
                throw "Multiple projects found"
            }
        }
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "Project") {
            Add-XmlElement $Project PackageReference ItemGroup ([ordered]@{
                Include = $package
                Version = $Version
            })   
            return
        }
        try {
            for ($i = 0; $i -lt $Source.Count; $i++) {
                $s=$Source[$i]
                $key+="<add key=`"$i`" value=`"$s`"/>"
            }
            $xml=@"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        $key
    </packageSources>
</configuration>
"@
            Set-Content .\Nuget.config $xml
            
            Invoke-Script{dotnet add package $Package}
        }
        finally {
            Remove-Item .\Nuget.config -Force -ErrorAction SilentlyContinue    
        }
        
    }
    
    end {
        
    }
}