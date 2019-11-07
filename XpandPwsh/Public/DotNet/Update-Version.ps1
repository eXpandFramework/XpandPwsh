function Update-Version {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Version,
        [switch]$Build,
        [switch]$Revision
    )
    
    begin {
        
    }
    
    process {
        $versionBuild=$newVersion.Build
        if ($Build){
            $versionBuild++
        }
        $versionRevision=$newRevision.Revision
        if ($Revision){
            $versionRevision++
        }
        $newVersion="$($Version.Major).$($Version.Minor).$versionBuild.$versionRevision"
        
        
    }
    
    end {
        
    }
}