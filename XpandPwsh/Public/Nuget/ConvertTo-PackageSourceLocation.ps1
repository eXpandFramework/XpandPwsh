function ConvertTo-PackageSourceLocation {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [string[]]$Source,
        [switch]$DoNotTestPath
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
        }|Sort-Object -Unique|Where-Object{
            if ($_ -notlike "http*" -and !$DoNotTestPath){
                if (Test-Path $_){
                    $_
                }
            }
            else{
                $_
            }
        }
        
    }
    end {
    }
}