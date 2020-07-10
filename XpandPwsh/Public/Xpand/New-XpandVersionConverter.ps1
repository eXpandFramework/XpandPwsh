function New-XpandVersionConverter {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Company,
        [version]$TargetPackageVersion="1.0.0",
        [string]$TargetMatch=$Company,
        [string]$ReferenceFilter="DevExpress*",
        [string]$TargetPackageAuthors=$Company,
        [string]$TargetPackageOwners=$Company,
        [string]$OutputDirectory=(Get-Location),
        [string]$BasePath=(Get-Location)
    )
    
    begin {
        $Company+=".Xpand.VersionConverter"
        if ($targetPath -notlike "(?is)"){
            $TargetMatch="(?is)$TargetMatch"
        }
    }
    
    process {
        
        $targetContent=@"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
        <ReferenceFilter>$ReferenceFilter</ReferenceFilter>
        <TargetFilter>$TargetMatch</TargetFilter>
    </PropertyGroup>
</Project>
"@
        $targetFileName="$env:Temp\$([Guid]::NewGuid()).targets"
        Set-Content $targetFileName $TargetContent
        $versionConverterVersion=Get-VersionPart ((Find-XpandPackage Xpand.VersionConverter Release).Version) Build
        $nuspecContent=@"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd">
    <metadata>
        <id>$Company</id>
        <version>$TargetPackageVersion</version>
        <authors>$TargetPackageAuthors</authors>
        <owners>$TargetPackageOwners</owners>
        <requireLicenseAcceptance>false</requireLicenseAcceptance>
        <description>This is a Xpand.VersionConverter configuration package.</description>
        <copyright></copyright>
        <dependencies>
            <dependency id="Xpand.VersionConverter" version="$versionConverterVersion" />
        </dependencies>
    </metadata>
    <files>
        <file src="$TargetFileName" target="build\$Company.targets" />
    </files>
</package>
"@
        $nuspecFileName="$env:Temp\$([Guid]::NewGuid()).nuspec"
        Set-Content $nuspecFileName $nuspecContent
        Invoke-NugetPack $nuspecFileName -OutputDirectory $OutputDirectory -Basepath $BasePath
    }
    
    end {
    }
}

