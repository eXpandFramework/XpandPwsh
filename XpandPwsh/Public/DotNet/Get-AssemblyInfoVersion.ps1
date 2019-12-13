function Get-AssemblyInfoVersion {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$assemblyInfo
    )
    
    begin {
        
    }
    
    process {
        $matches = Get-Content $assemblyInfo -ErrorAction Stop | Select-String 'public const string Version = \"([^\"]*)'
        if ($matches) {
            $matches[0].Matches.Groups[1].Value
        }
        else {
            throw "Version info not found in $assemblyInfo"
        }
    }
    
    end {
        
    }
}