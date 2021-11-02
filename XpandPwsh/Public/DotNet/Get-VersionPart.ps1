function Get-VersionPart {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        $Version,
        [ValidateSet("Build","Minor")]
        [string]$Part="Build"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        $semVersion=Get-SemanticVersion $version
        if ($semVersion){
            $Version=$semVersion
        }
        else{
            $Version=[version]::new($Version)
        }
        $v=$Version.Major.ToString()        
        $v+="."
        $v+=$Version.Minor
        if ($Part -eq "Build"){
            $v+="."
            if (!$Version.Build){
                $v+=$Version.Patch
            }
            else{
                $v+=$Version.Build
            }
            
        }
        $v
    }
    
    end {
        
    }
}