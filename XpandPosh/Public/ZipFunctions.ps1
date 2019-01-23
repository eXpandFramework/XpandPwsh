Function Start-UnZip {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True, mandatory = $True)]
        [string]$fileName,
        [string]$dir
    )
    Begin {
        Write-Verbose "Initialize stuff in Begin block"
    }

    Process {
        Add-Type -Assembly System.IO.Compression.FileSystem
        $targetDir = $dir
        if ($dir -eq "") {
            $targetDir = Split-Path $fileName
        }
        Write-Verbose "Unzipping $fileName into $targetDir"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($fileName, $targetDir)
    }

    End {
        Write-Verbose "Final work in End block"
    }
}

Function Start-Zip {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True, mandatory = $True)]
        [string]$fileName,
        [string]$dir,
        [System.IO.Compression.CompressionLevel]$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal,
        [bool]$deleteAfterArchiving
    )
    Begin {
        Write-Verbose "Initialize stuff in Begin block"
    }

    Process {
        Add-Type -Assembly System.IO.Compression.FileSystem
        $tempDir = [System.IO.Path]::GetTempPath()
        $targetDir = $dir
        if ($dir -eq "") {
            $targetDir = Split-Path $fileName
        }
        $fileNameWithoutPath = [io.path]::GetFileName($fileName)
        $tempFileName = [io.path]::Combine($tempDir, $fileNameWithoutPath)
        Write-Verbose "Zipping $fileName into $tempDir"
        [System.IO.Compression.ZipFile]::CreateFromDirectory($targetDir, $tempFilename, $compressionLevel, $false)
        Copy-Item -Force -Path $tempFileName -Destination $fileName
        Remove-Item -Force -Path $tempFileName
        if ($deleteAfterArchiving) {
            Get-ChildItem -Path $targetDir -Exclude $fileNameWithoutPath -Recurse | Select-Object -ExpandProperty FullName | Remove-Item -Force -Recurse
        }
    }

    End {
        Write-Verbose "Final work in End block"
    }
}

function Start-ZipProject() {
    Get-ChildItem -Recurse | 
        Where-Object { $_.PSIsContainer } | 
        Where-Object { $_.Name -eq 'bin' -or $_.Name -eq 'packages' -or $_.Name -eq 'obj' -or $_.Name -eq '.vs' -or $_.Name.StartsWith('_ReSharper')} | 
        Remove-Item -Force -Recurse 
    
    $zipFileName = [System.IO.Path]::Combine($currentLocation, $zipFileName)
    Start-Zip -fileName $zipFileName 
}