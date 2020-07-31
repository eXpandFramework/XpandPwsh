function Join-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo[]]$Video,
        [parameter()]
        [string]$OutputFile
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        $e=@()
        if (!$outputFile){
            $outputFile="output.mp4"
        }
    }
    
    process {
        $e+="-i $($Video.FullName)"
    }
    
    end {
        Invoke-Script{
            Push-Location (Get-Item $Video|Select-Object -First 1).DirectoryName
            $format=[System.IO.Path]::GetExtension($outputFile).Substring(1)
            Remove-Item $outputFile -ErrorAction SilentlyContinue
            
            $e+="-filter_complex concat=n=$($e.Length-1):v=1:a=0"
            $e+="-f $format"
            $e+="-vn"
            $e+="-y"
            $e+=$outputFile
            Start-Process ffmpeg.exe $e -WorkingDirectory (Get-Location) -NoNewWindow
            Get-Item $OutputFile
            Pop-Location
        }
        
    }
}