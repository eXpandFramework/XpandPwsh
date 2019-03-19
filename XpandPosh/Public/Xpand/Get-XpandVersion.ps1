function Get-XpandVersion { 
    [CmdletBinding()]
    param(
        $XpandPath,
        [switch]$Latest,
        [switch]$Release,
        [switch]$Lab,
        [switch]$Next
    )
    if ($Next) {
        $official = Get-XpandVersion -Release
        Write-Verbose "Release=$official"
        $labVersion = Get-XpandVersion -Lab 
        Write-Verbose "lab=$labVersion"
        $revision = 0
        $dxVersion=Get-DevExpressVersion -Latest
        Write-Verbose "dx=$dxVersion"
        $build="$($dxVersion.Build)00"
        if (($official.Build -like "$($dxVersion.build)*")){
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
        
        return New-Object System.Version($dxVersion.Major, $dxVersion.Minor, $build, $revision)
    }
    if ($XpandPath) {
        $assemblyInfo = "$XpandPath\Xpand\Xpand.Utils\Properties\XpandAssemblyInfo.cs"
        $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String 'public const string Version = \"([^\"]*)'
        if ($matches) {
            return New-Object System.Version($matches[0].Matches.Groups[1].Value)
        }
        else {
            Write-Error "Version info not found in $assemblyInfo"
        }
        return
    }
    if ($Latest) {
        $official = Get-XpandVersion -Release
        $labVersion = Get-XpandVersion -Lab 
        if ($labVersion -gt $official) {
            $labVersion
        }
        else {
            $official
        }
        return
    }
    if ($Lab) {
        return (& $(Get-NugetPath) list eXpand -Source (Get-PackageFeed -Xpand)|ConvertTo-PackageObject -LatestVersion|Sort-Object -Property Version -Descending |Select-Object -First 1).Version
    }
    if ($Release) {
        return (& $(Get-NugetPath) list eXpand -Source (Get-PackageFeed -Nuget)|Where-Object{$_ -like "eXpand*"}|ConvertTo-PackageObject|Sort-Object -Property Version -Descending |Select-Object -First 1).Version
    }
}