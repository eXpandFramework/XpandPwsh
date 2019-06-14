function Get-PackageTargetFramework {
    [CmdletBinding()]
    param (
        $id,
        $version,
        $TargetFramework,
        $TargetFrameworkVersion
    )
    
    begin {
    }
    
    process {
        $packagesFolder=Find-NugetPackageInstallationFolder $id $version
        $targets = Get-ChildItem "$packagesFolder\$Id\$Version\lib" | ForEach-Object {
            $_.BaseName.Split("-")|ForEach-Object{$_.split("+")} | ForEach-Object {
                $regex = [regex] '(?ix)([^\d]*)(.*)'
                $result = $regex.Match($_);
                [PSCustomObject]@{
                    Name = $result.Groups[1].Value
                    Version=$result.Groups[2].Value
                }
            }
        } | Where-Object { $_.Name -eq "$targetFramework" }
        $matchedTargets=$targets | ForEach-Object {
            $v=$_.Version.Replace(".","")
            if ($v -lt $TargetFrameworkVersion -or $v -eq $TargetFrameworkVersion) {
                "$($_.Name)$($_.Version)"
            }
        } 
        $matchedTargets | Sort-Object -Descending | Select-Object -First 1
    }
    
    end {
    }
}

