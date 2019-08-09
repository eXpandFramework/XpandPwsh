function Start-XpandProjectConverter {
    [CmdletBinding()]
    param (
        [string]$Path=(Get-location),
        [parameter()]
        [ValidateSet("csproj","vbproj")]
        [string]$ProjectType="csproj",
        [ValidateSet("All", "Release", "Lab")]
        [string]$PackageSource = "Release"
    )
    
    begin {
    }
    
    process {
        $xpandPath=Get-XpandPath
        if (!(Test-Path $xpandPath)){
            throw "This cmdlet works only for eXpandFramework installer and is not found installed"
        }
        $packages=Get-ChildItem $xpandPath "Xpand*.dll"|ForEach-Object{
            $version=[System.Diagnostics.FileVersionInfo]::GetVersionInfo($_.FullName).FileVersion
            [PSCustomObject]@{
                Id = $_.BaseName
                Version=$version
            }
        }
        Get-ChildItem $Path "*.$ProjectType" -Recurse|ForEach-Object{
            [xml]$csproj=Get-Content $_.FullName
            $csproj.Project.ItemGroup.Reference|Where-Object{$_.include -like "Xpand*" }|ForEach-Object{
                $regex = [regex] '(?ix)([^,"]*)'
                $result = $regex.Match($_.Include).Value;
                $package=$packages|Where-Object{$_.Id -eq $result}
                $_.Include="$result, Version=$($package.Version), Culture=neutral, PublicKeyToken=c52ffed5d5ff0958, processorArchitecture=MSIL"
            }
            $csproj.Save($_.FullName)
        }
    }
    
    end {
    }
}