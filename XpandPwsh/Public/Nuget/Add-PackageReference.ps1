function Add-PackageReference {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string]$Package,
        [string[]]$Source=(Get-PackageSourceLocations)
    )
    
    begin {
        $projects=Get-ChildItem *.*proj
        if (!$projects){
            throw "Projects not found"
        }
        if ($projects.count -gt 1){
            $projects
            throw "Multiple projects found"
        }
    }
    
    process {
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