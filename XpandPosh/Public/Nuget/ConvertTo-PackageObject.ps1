function ConvertTo-PackageObject {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$item,
        [switch]$LatestVersion
    )
    
    begin {
        if ($LatestVersion){
            $list=New-Object System.Collections.Arraylist
        }
    }
    
    process {
        
        $strings = $item.Split(" ")
        $psobj=[PSCustomObject]@{
            Name    = $strings[0]
            Version = new-object System.Version ($strings[1])
        }
        if ($LatestVersion){
            $list.Add($psObj)|Out-Null
        }
        else{
            $psobj
        }
    }
    
    end {
        if ($LatestVersion){
            $list|Group-Object -Property Name|ForEach-Object{
                ($_.Group|Sort-Object -Property Version -Descending|Select-Object -First 1)
            }
        }
    }
}
