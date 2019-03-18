function Get-XpandVersion { 
    param(
        $XpandPath,
        [switch]$Latest,
        [switch]$Release,
        [switch]$Lab,
        [switch]$Next
    )
    if ($Next) {
        $official = Get-XpandVersion -Release
        Write-Verbose $official
        $labVersion = Get-XpandVersion -Lab 
        Write-Verbose $labVersion
        $revision = 0
        $dxVersion=Get-DevExpressVersion -Latest
        Write-Verbose $dxVersion
        $build="$($dxVersion.Build)00"
        if ($official.Build -like "$($dxVersion.build)*"){
            if ($official.Build -eq $labVersion.Build) {
                $revision = $labVersion.Revision + 1
                if ($labVersion.Revision -eq -1) {
                    $revision = 1
                }
                $build=$official.Build
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
        (& nuget list eXpand -Source https://xpandnugetserver.azurewebsites.net/nuget|ConvertTo-PackageObject -LatestVersion|Sort-Object -Property Version -Descending |Select-Object -First 1).Version
        return
    }
    if ($Release) {
        $c = New-Object System.Net.WebClient
        $c.Headers.Add("User-Agent", "Xpand");
        New-Object System.Version (($c.DownloadString("https://api.github.com/repos/eXpand/eXpand/releases/latest")|ConvertFrom-Json).tag_Name)
        $c.Dispose()
    }
}