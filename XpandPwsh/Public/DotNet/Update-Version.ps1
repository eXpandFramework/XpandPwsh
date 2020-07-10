function Update-Version {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(Mandatory)]
        [string]$Version,
        [switch]$Major,
        [switch]$Minor,
        [switch]$Build,
        [switch]$KeepBuild,
        [switch]$Revision
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin        
    }
    
    process {
        $newVersion=[version]$Version
        $versionMajor=$newVersion.Major
        $versionMinor=$newVersion.Minor
        $versionBuild=$newVersion.Build
        $versionRevision=$newVersion.Revision
        if ($Major){
            $versionMajor++
            $versionMinor=0
            if (!$KeepBuild){
                $versionBuild=0
            }
            $versionRevision=0
        }
        elseif ($Minor){
            $versionMinor++
            if (!$KeepBuild){
                $versionBuild=0
            }
            $versionRevision=0
        }
        elseif ($Build){
            $versionBuild++
            $versionRevision=0
        }
        elseif ($Revision){
            $versionRevision++
        }
        [version]"$($versionMajor).$versionMinor.$versionBuild.$versionRevision"
    }
    
    end {
        
    }
}