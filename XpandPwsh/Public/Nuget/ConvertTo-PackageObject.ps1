function ConvertTo-PackageObject {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$item
    )
    
    begin {
        
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
        $psobj
    }
    
    end {
        
    }
}
