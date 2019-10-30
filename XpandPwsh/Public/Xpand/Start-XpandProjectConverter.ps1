function Start-XpandProjectConverter {
    [CmdletBinding()]
    param (
        [parameter(ParameterSetName = "XAFPackages")]
        [string]$version,
        [parameter(ParameterSetName = "XAFPackages")]
        [string]$Packagepath,
        [string]$Path = (Get-Location),
        [parameter()]
        [ValidateSet("csproj", "vbproj")]
        [string]$ProjectType = "csproj",
        [ValidateSet("Installer", "XAFPackages")]
        [string]$Mode = "Installer"
    )
    
    begin {
    }
    
    process {
        if ($Mode -eq "Installer") {
            $xpandPath = Get-XpandPath
            $packages = Get-ChildItem $xpandPath "Xpand*.dll" | ForEach-Object {
                $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($_.FullName).FileVersion
                [PSCustomObject]@{
                    Id      = $_.BaseName
                    Version = $version
                }
            }
            Get-ChildItem $Path "*.$ProjectType" -Recurse | ForEach-Object {
                [xml]$csproj = Get-Content $_.FullName
                $csproj.Project.ItemGroup.Reference | Where-Object { $_.include -like "Xpand*" } | ForEach-Object {
                    $regex = [regex] '(?ix)([^,"]*)'
                    $result = $regex.Match($_.Include).Value;
                    $package = $packages | Where-Object { $_.Id -eq $result }
                    $_.Include = "$result, Version=$($package.Version), Culture=neutral, PublicKeyToken=c52ffed5d5ff0958, processorArchitecture=MSIL"
                }
                $csproj.Save($_.FullName)
            }
        }
        else {
            [version]$systemversion = $version
            $dxversion = "$($systemversion.Major).$($systemversion.Minor).$($systemversion.Build)"
            & "..\..\Private\projectconverter-console.exe" $Path /b /d:skipped /xv:$dxversion
            if ($Packagepath){
                Switch-XpandToNugets -Path $Path -PackageSource $Packagepath
            }
            
        }
    }
    
    end {
    }
}