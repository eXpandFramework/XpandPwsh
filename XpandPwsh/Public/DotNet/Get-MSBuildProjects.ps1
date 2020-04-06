function Get-MSBuildProjects {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [System.Management.Automation.PathInfo]$Path=(Get-Location)
    )
    
    begin {
        
    }
    
    process {
        Get-ChildItem . *.*proj -Recurse
    }
    end {
        
    }
}