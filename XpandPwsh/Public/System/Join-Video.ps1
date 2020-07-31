function Join-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo[]]$Video,
        [parameter()]
        [string]$OutputFile="output.mp4"
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        $files=@()
    }
    
    process {
        $files+="-i"
        $files+=$Video.FullName
    }
    
    end {
        Remove-Item $OutputFile -ErrorAction SilentlyContinue
        Push-Location (Get-Item $Video|Select-Object -First 1).DirectoryName
        Invoke-Script{
            $format=[System.IO.Path]::GetExtension($outputFile)
            ffmpeg @files -filter_complex "concat=n=$($files.Length):v=1:a=0" -f $format -vn -y $outputFile   
        }
        Get-Item $OutputFile
        Pop-Location
    }
}