function Add-PackageReferenceNoWarning {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [xml]$Project,
        [parameter()]
        [string[]]$Warning,
        [parameter(Mandatory)]
        [string]$PackageMatch
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        $Project.Project.ItemGroup.PackageReference |Where-Object{$_.Include -match $PackageMatch}|ForEach-Object{
            $package=$_
            $Warning|ForEach-Object{
                $noWarn=$_
                if (!($package.NoWarn|Where-Object{$_ -eq $noWarn})){
                    Add-XmlElement -Owner $Project -ElementName "NoWarn" -ParentNode $package -InnerText $_
                }
            }
        }
    }
    
    end {
        
    }
}