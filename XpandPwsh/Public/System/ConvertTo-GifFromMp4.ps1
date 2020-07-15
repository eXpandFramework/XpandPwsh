function ConvertTo-GifFromMp4{
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Mp4Path,
        [parameter()]
        [string]$OutputFile
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
        if (!$OutputFile){
            $OutputFile="$($Mp4Path.DirectoryName)\$($Mp4Path.BaseName).gif"
        }
    }
    
    process {
        Invoke-Script{
            Push-Location $Mp4Path.DirectoryName
            Remove-Item $OutputFile -ErrorAction SilentlyContinue
            ffmpeg -i $Mp4Path.Name -vf "fps=7" -loop 0 $OutputFile
            Pop-Location
        }
    }
    
    end {
        
    }
}