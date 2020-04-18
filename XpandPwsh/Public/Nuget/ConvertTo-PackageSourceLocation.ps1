function ConvertTo-PackageSourceLocation {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory)]
        [string[]]$Source
        
    )
    
    begin {
    }
    
    process {
        $allSources=Get-PackageSource
        $Source|ForEach-Object{
            $item=$_
            $match=$allSources|Where-Object{$_.Name -eq $item}
            if ($match ) {
                $match.Location
            }
            else{
                $_
            }
        }|Sort-Object -Unique
        
    }
    end {
    }
}