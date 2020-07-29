function Split-GifToImages{
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$GifPath,
        [parameter()]
        [string]$OutputDirectory=$GifPath.DirectoryName
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        if (!(Get-Chocopackage ffmpeg)){
            Install-ChocoPackage ffmpeg
        }
    }
    
    process {
        Invoke-Script{
            Push-Location $GifPath.DirectoryName
            New-Item $GifPath.BaseName -ItemType Directory -ErrorAction SilentlyContinue
            Copy-Item $GifPath $GifPath.BaseName
            Push-Location $GifPath.BaseName
            ffmpeg -i $GifPath.Name -vsync 0 "$($GifPath.BaseName)%d.png"
            Get-ChildItem "$($GifPath.BaseName)*.png"
            Pop-Location
            Pop-Location
        }
    }
    
    end {
        
    }
}