function Join-Video {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$Video,
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
        Install-NpmPackage gifsicle|Out-Null
    }
    
    process {
        $e+=$Video.FullName
        
    }
    
    end {
        Push-Location (Get-Item $Video|Select-Object -First 1).DirectoryName
        $format=[System.IO.Path]::GetExtension($outputFile).Substring(1)
        Remove-Item $outputFile -ErrorAction SilentlyContinue
        if ($format -eq "Gif" -and  ((Get-Item ($e|Select-Object -First 1)).extension -eq ".Gif")){
            Invoke-Script{gifsicle --merge @e -o $outputFile --colors 256}
        }
        else{
            $e+="-filter_complex `"concat=n=$($e.Length):v=1:a=0`""
            $e+="-f $format"
            $e+="-vn"
            $e+="-y"
            
            $e+=$outputFile
            
            Start-Process ffmpeg.exe $e -WorkingDirectory (Get-Location) -NoNewWindow -Wait
        }
        
        Get-Item $OutputFile
        Pop-Location
        
    }
}