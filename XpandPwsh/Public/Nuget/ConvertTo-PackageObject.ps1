function ConvertTo-PackageObject {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter(ValueFromPipeline)]
        $item,
        [switch]$NewFormat
    )
    
    begin {
        
    }
    
    process {
        if ($item -eq "No packages found." -or !$item) {
            return
        }
        if ($NewFormat){
            $pattern = '> (\S+) \| (\d+\.\d+\.\d+) \|'
            $matches = [regex]::Matches($item, $pattern)

            foreach ($match in $matches) {
                [PSCustomObject]@{
                    Id = $match.Groups[1].Value
                    Version     = $match.Groups[2].Value
                }
            
            }
            return
        }
        $strings = "$item".Split(" ")
        if ($strings.Length -eq 2) {
            $v = New-Object System.Version ($strings[1])
            [PSCustomObject]@{
                Id      = $strings[0]
                Version = $v
            }
        }
        else {
            if ([System.IO.File]::Exists($item)){
                $item=Get-Item $item
            }
            $name=$item
            if ($item -is [System.IO.FileInfo]){
                $name=$item.basename
            }
            

            $regex = [regex] '(?imn)\.(?<version>[\d]+\.[\d]+\.[\d]+(\.[\d]+)?)$'
            $v = $regex.Match($name).Groups["version"].Value
            $id=$name.replace(".$v","")
            $o = @{
                Id = $id
                Version=$v
            }
            if ($item -is [System.IO.FileInfo]){
                $o.Add("File",$item)
            }
            [pscustomObject]$o
        }
        
    }
    
    end {
        
    }
}
