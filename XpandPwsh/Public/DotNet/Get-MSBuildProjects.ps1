function Get-MSBuildProjects {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#monocecil"))]
    param (
        [parameter()][string]$Path=(Get-Location),
        [parameter()][string[]]$Include,
        [parameter()][string[]]$Excude
    )
    
    begin {
        
    }
    
    process {
        $a = @{}
        if ($Include){
            $a.Add("Include",$Include)
        }
        if ($Excude){
            $a.Add("Exclude",$Excude)
        }
        Get-ChildItem $Path *.*proj -Recurse @a
    }
    end {
        
    }
}