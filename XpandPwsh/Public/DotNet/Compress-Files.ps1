function Compress-Files {
    [CmdletBinding()]
    param (
        [string]$path =".",
        [parameter(Mandatory)]
        [string]$zipfileName,
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    )
    
    begin {
        Add-Type -Assembly System.IO.Compression.FileSystem
    }
    
    process {
        [System.IO.Compression.ZipFile]::CreateFromDirectory($path,
            $zipfilename, $compressionLevel, $false)
        
    }
    
    end {
    }
}