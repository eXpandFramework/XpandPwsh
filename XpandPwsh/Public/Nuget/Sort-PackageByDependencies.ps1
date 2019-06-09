function Sort-PackageByDependencies {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        $psObj
    )
    begin {
        $all=New-Object System.Collections.ArrayList
    }
    
    process {
        $all.Add($psObj)|Out-Null
    }
    
    end {
        $list=New-Object System.Collections.ArrayList
        
        while ($all.Count) {
            $all|ForEach-Object{
                $obj=$_
                $deps=$obj.Metadata.Metadata.DependencySets.Packages|select -ExpandProperty Id
                $exist=$all|Select-Object -ExpandProperty Id|Where-Object{$deps -contains $_}
                if (!$exist){
                    $list.Add($obj)|out-null
                }
            }
            $list|ForEach-Object{
                $all.Remove($_)|out-null
            }
        }
        $list|ForEach-Object{$_}
    }
}



