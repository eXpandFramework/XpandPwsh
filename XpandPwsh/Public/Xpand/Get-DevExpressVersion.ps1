function Get-DevExpressVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ParameterSetName = "version",Position=0,ValueFromPipeline)]
        [string]$Version,
        [parameter(ParameterSetName = "version")]
        [switch]$Build,
        [parameter(ParameterSetName = "latest")]
        [string]$LatestVersionFeed="https://xpandnugetserver.azurewebsites.net/nuget"
    )
    
    begin {
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "version") {
            $v = New-Object System.Version $version
            if (!$build) {
                "$($v.Major).$($v.Minor)"
            }    
            else {
                $vbuild=$v.Build
                if ($vbuild.ToString().Length -gt 2){
                    $vbuild=$vbuild.ToString().Substring(0,$vbuild.ToString().Length-2)
                }
                "$($v.Major).$($v.Minor).$($vBuild)"
            }
        }
        else{
            (Get-NugetPackageSearchMetadata -Name DevExpress.ExpressApp.Reports -Source $LatestVersionFeed).identity.Version.OriginalVersion
            
        }
        
    }
    
    end {
    }
}
