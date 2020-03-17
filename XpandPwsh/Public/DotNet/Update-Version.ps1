function Update-Version {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory)]
        [string]$Version,
        [switch]$Minor,
        [switch]$Build,
        [switch]$Revision
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        $newVersion=[version]$Version
        $versionMinor=$newVersion.Minor
        $versionBuild=$newVersion.Build
        $versionRevision=$newVersion.Revision
        if ($Minor){
            $versionMinor++
            $versionBuild=0
            $versionRevision=0
        }
        elseif ($Build){
            $versionBuild++
            $versionRevision=0
        }
        elseif ($Revision){
            $versionRevision++
        }
        [version]"$($newVersion.Major).$versionMinor.$versionBuild.$versionRevision"
    }
    
    end {
        
    }
}