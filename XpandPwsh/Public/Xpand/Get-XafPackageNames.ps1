function Get-XafPackageNames{
    [CmdLetTag()]
    param(
        [parameter(Mandatory)]
        [string[]]$Version,
        [ValidateSet("Core","Win","Web")]
        [string[]]$Platform=@("Win","Web","Core"),
        [parameter()]
        [string]$DXFeed=$env:DxFeed
    )
    ($Platform|ForEach-Object{
        Get-NugetPackageDependencies DevExpress.ExpressApp.$_.All -Source $DXFeed -FilterRegex "DevExpress.ExpressApp.*|DevExpress.Persistent.*" -Recurse
    }|Sort-Object Id -Unique|Where-Object{
        !$Version -or $_.VersionRange.MaxVersion -in $Version
    }).Id
}