function Get-VersionPart {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [version]$Version,
        [ValidateSet("Build","Minor")]
        [string]$Part="Build"
    )
    
    begin {
        
    }
    
    process {
        $v=$Version.Major.ToString()        
        $v+="."
        $v+=$Version.Minor
        if ($Part -eq "Build"){
            $v+="."
            $v+=$Version.Build
        }
        $v
    }
    
    end {
        
    }
}