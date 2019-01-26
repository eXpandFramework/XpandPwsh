
Function Compress-Files {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True, mandatory = $True)]
        [string]$DestinationPath,
        [string]$Path,
        [System.IO.Compression.CompressionLevel]$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal,
        [switch]$deleteAfterArchiving
    )
    Begin {
        Write-Verbose "Initialize stuff in Begin block"
    }

    Process {
        Add-Type -Assembly System.IO.Compression.FileSystem
        $tempDir = [System.IO.Path]::GetTempPath()
        $targetDir = $Path
        if ($Path -eq "") {
            $targetDir = Split-Path $DestinationPath
        }
        $DestinationPathWithoutPath = [io.path]::GetFileName($DestinationPath)
        $tempFileName = [io.path]::Combine($tempDir, $DestinationPathWithoutPath)
        Write-Verbose "Zipping $DestinationPath into $tempDir"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($targetDir, $tempFilename, $compressionLevel, $false)
        Copy-Item -Force -Path $tempFileName -Destination $DestinationPath
        Remove-Item -Force -Path $tempFileName
        if ($deleteAfterArchiving) {
            Get-ChildItem -Path $targetDir -Exclude $DestinationPathWithoutPath -Recurse | Select-Object -ExpandProperty FullName | Remove-Item -Force -Recurse
        }
    }

    End {
        Write-Verbose "Final work in End block"
    }
}

function Compress-Project() {
    Get-ChildItem -Recurse | 
        Where-Object { $_.PSIsContainer } | 
        Where-Object { $_.Name -eq 'bin' -or $_.Name -eq 'packages' -or $_.Name -eq 'obj' -or $_.Name -eq '.vs' -or $_.Name.StartsWith('_ReSharper')} | 
        Remove-Item -Force -Recurse 
    
    $zipFileName = [System.IO.Path]::Combine($currentLocation, $zipFileName)
    Compress-Files -DestinationPath $zipFileName -Path .
}