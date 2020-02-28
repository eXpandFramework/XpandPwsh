function Update-Version {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory)]
        [string]$Version,
        [switch]$Build,
        [switch]$Revision
    )
    
    begin {
        
    }
    
    process {
        $newVersion=[version]$Version
        $versionBuild=$newVersion.Build
        $versionRevision=$newVersion.Revision
        if ($Build){
            $versionBuild++
            $versionRevision=0
        }
        
        if ($Revision -and !$Build){
            $versionRevision++
        }
        [version]"$($newVersion.Major).$($newVersion.Minor).$versionBuild.$versionRevision"
    }
    
    end {
        
    }
}