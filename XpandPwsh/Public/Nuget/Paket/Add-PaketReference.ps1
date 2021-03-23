function Add-PaketReference {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.DirectoryInfo]$Directory,
        [parameter(Mandatory)]
        [string]$Package,
        [switch]$Recurse
    )
    
    begin {
        
    }
    
    process {
        Get-ChildItem $Directory.FullName paket.references -Recurse:$Recurse|Add-ContentLine -Line $Package 
    }
    
    end {
        
    }
}