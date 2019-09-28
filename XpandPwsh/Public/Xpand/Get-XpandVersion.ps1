function Get-XpandVersion { 
    [CmdletBinding()]
    param(
        $XpandPath,
        [switch]$Latest,
        [switch]$Release,
        [switch]$Lab,
        [parameter(ParameterSetName="Next")]
        [switch]$Next,
        [parameter(ParameterSetName="Next",Mandatory)]
        $OfficialPackages,
        [parameter(ParameterSetName="Next",Mandatory)]
        $LabPackages,
        $DXVersion,
        [string]$Module="eXpand*"
    )
    if ($Next) {
        $official = ($OfficialPackages|where-object{$_.Name -eq $Module}).Version
        Write-Verbose "Release=$official"
        $labVersion = ($labPackages|where-object{$_.Name -eq $Module}).Version
        Write-Verbose "lab=$labVersion"
        $revision = 0
        $baseVersion=$DXVersion
        if ($Module -ne "eXpand*" ){
            if ($labVersion -lt $official){
                $baseVersion=$official
            }
            else{
                $baseVersion=$labVersion
            }
            $build=$baseVersion.Build
            if (!$official -and !$baseVersion){
                return
            }
        }
        else{
            $build="$($baseVersion.Build)00"
        }
        Write-Verbose "baseVersion=$baseVersion"
        
        if ((($official.Build -like "$($baseVersion.build)*"))){
            if ($official.Build -eq $labVersion.Build) {
                $revision = $labVersion.Revision + 1
                if ($labVersion.Revision -eq -1) {
                    $revision = 1
                }
                $build=$official.Build
            }
            elseif ($official.Build -gt $labVersion.Build) {
                $build=$official.Build
                $revision=1
            }
        }
        else{
            $revision = $labVersion.Revision + 1
            if ($labVersion.Revision -eq -1) {
                $revision = 1
            }
        }
        return New-Object System.Version($baseVersion.Major, $baseVersion.Minor, $build, $revision)
    }
    if ($XpandPath) {
        $assemblyIndoName="AssemblyInfo"
        $pattern='AssemblyVersion\("([^"]*)'
        if ($Module -eq "eXpand*"){
            $assemblyInfoPath="Xpand\Xpand.Utils"
            $assemblyIndoName="XpandAssemblyInfo"
            $pattern='public const string Version = \"([^\"]*)'
        }
        $assemblyInfo = "$XpandPath\$assemblyInfoPath\Properties\$assemblyIndoName.cs"
        
        $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String $pattern
        if ($matches) {
            return New-Object System.Version($matches[0].Matches.Groups[1].Value)
        }
        else {
            Write-Error "Version info not found in $assemblyInfo"
        }
        return
    }
    if ($Latest) {
        $official = Get-XpandVersion -Release -Module $Module
        $labVersion = Get-XpandVersion -Lab -Module $Module
        if ($labVersion -gt $official) {
            $labVersion
        }
        else {
            $official
        }
        return
    }
    if ($Lab) {
        return (Find-XpandPackage $Module -PackageSource lab|Sort-Object Version -Descending |Select-Object -First 1).Version
    }
    if ($Release) {        
        return (Find-XpandPackage $Module -PackageSource  Release  |Sort-Object Version -Descending |Select-Object -First 1).Version
    }
}