function Add-PaketReference {
    [CmdletBinding()]
    [CmdLetTag(("#nuget","#paket"))]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.DirectoryInfo]$Directory,
        [parameter(Mandatory)]
        [string]$Package
    )
    
    begin {
        
    }
    
    process {
        Get-ChildItem $Directory.FullName paket.references|Add-ContentLine -Line $Package 
    }
    
    end {
        
    }
}