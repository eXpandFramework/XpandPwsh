function Get-PaketPackageRequirement {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [Paket.DependenciesFile]$DepsFile,
        [parameter()]
        [string]$Filter="*",
        [string]$Group="Main"
    )
    
    begin {
        
    }
    
    process {
        $DepsFile.Groups|ForEach-Object{$_.Value}|Where-Object{$_.Name -like $Group}|ForEach-Object{
            $_.packages|Where-Object{$_.Name -like $filter}
        }
    }
    
    end {
        
    }
}