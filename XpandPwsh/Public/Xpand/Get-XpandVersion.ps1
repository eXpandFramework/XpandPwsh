function Get-XpandVersion { 
    [CmdletBinding()]
    [CmdLetTag()]
    param(
        $XpandPath,
        [switch]$Latest,
        [switch]$Release,
        [switch]$Lab,
        [parameter(ParameterSetName="Next")]
        [switch]$Next,
        [parameter(ParameterSetName="Next")]
        $OfficialPackages,
        [parameter(ParameterSetName="Next")]
        $LabPackages,
        [parameter(ParameterSetName="Next")]
        [version]$DXVersion,
        [string]$Module="eXpand*"
    )
    if (!$OfficialPackages -and !$XpandPath){
        $OfficialPackages=Find-XpandPackage $Module -PackageSource Release
        $labPackages=Find-XpandPackage $Module -PackageSource Lab
    }
    $official = ($OfficialPackages|where-object{$_.Id -like $Module}).Version
    $labVersion = ($labPackages|where-object{$_.Id -like $Module}).Version
    if ($Module -eq "eXpand*"){
        $official=$official|ForEach-Object{[version]$_}|Sort-Object -Descending |Select-Object -First 1
        $labVersion=$labVersion|ForEach-Object{[version]$_}|Sort-Object -Descending |Select-Object -First 1
    }
    Write-Verbose "Release=$official"
    Write-Verbose "lab=$labVersion"
    if ($Next) {
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
            $build=$baseVersion.Build
            if ($build -like "$($labVersion.Build)*"){
                $revision = $labVersion.Revision + 1
            }
            else{
                $revision=0
            }
            
            if ($labVersion.Revision -eq -1) {
                $revision = 1
            }
        }
        $nextVersion= New-Object System.Version($baseVersion.Major, $baseVersion.Minor, $build, $revision)
        if ($labVersion){
            $Semester=1
            if ([datetime]::Now.Month -gt 6){
                $Semester++
            }
            if ($nextVersion -lt "$($nextVersion.Major).$([datetime]::Now.ToString('yy'))$Semester.0"){
                $nextVersion=Update-Version $nextVersion -Minor -KeepBuild
            }
        }
        return $nextVersion
    }
    if ($XpandPath) {
        $assemblyIndoName="AssemblyInfo"
        $pattern='AssemblyVersion\("([^"]*)'
        $assemblyInfoPath=$null
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