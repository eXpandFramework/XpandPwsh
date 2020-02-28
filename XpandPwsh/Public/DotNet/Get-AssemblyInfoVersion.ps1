function Get-AssemblyInfoVersion {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileInfo]$assemblyInfo
    )
    
    begin {
        
    }
    
    process {
        $c = Get-Content $assemblyInfo -ErrorAction Stop 
        $matches = $c | Select-String 'public const string Version = \"([^\"]*)'
        if ($matches) {
            $matches[0].Matches.Groups[1].Value
        }
        else {
            $matches = $c | Select-String 'AssemblyVersion\(\"([^\"]*)'
            if ($matches) {
                $matches[0].Matches.Groups[1].Value
            }
        }
        if (!$matches){
            throw "Version info not found in $assemblyInfo"
        }
        
    }
    
    end {
        
    }
}