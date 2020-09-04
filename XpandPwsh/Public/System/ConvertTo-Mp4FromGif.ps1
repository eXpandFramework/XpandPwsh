function ConvertTo-Mp4FromGif {
    [CmdletBinding()]
    [CmdLetTag("#ffmpeg")]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$GifPath,
        [parameter()]
        [string]$OutputFile
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        
    }
    
    process {
        if (!$OutputFile){
            $OutputFile="$($GifPath.DirectoryName)\$($GifPath.BaseName).mp4"
        }
        Remove-Item $OutputFile -ErrorAction SilentlyContinue
         
        Invoke-Script{ffmpeg -f gif -loglevel panic -i $GifPath.FullName -y -hide_banner  $OutputFile}
        Get-Item $OutputFile
    }
    
    end {
        
    }
}