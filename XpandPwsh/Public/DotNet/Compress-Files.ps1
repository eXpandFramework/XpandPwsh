function Compress-Files {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [string]$path =".",
        [parameter(Mandatory)]
        [string]$zipfileName,
        [System.IO.Compression.CompressionLevel]$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal,
        [switch]$Force
    )
    
    begin {
        Add-Type -Assembly System.IO.Compression.FileSystem
    }
    
    process {
        if ($Force){
            if (Test-Path $zipfileName){
                Remove-Item $zipfileName
            }
        }
        [System.IO.Compression.ZipFile]::CreateFromDirectory($path,
            $zipfilename, $compressionLevel, $false)
        
    }
    
    end {
    }
}