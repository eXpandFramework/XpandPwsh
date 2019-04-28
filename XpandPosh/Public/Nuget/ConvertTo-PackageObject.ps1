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
        if ($item -eq "No packages found."){
            return
        }
        $strings = $item.Split(" ")
        if ($strings.Length -eq 2){
            $v=new-object System.Version ($strings[1])
        }
        $psobj=[PSCustomObject]@{
            Id    = $strings[0]
            Version = $v
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
