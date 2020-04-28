function Install-ImageMagic {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        Install-Chocolatey
        if (!(Get-ChocoPackage imagemagick.app)){
            choco install imagemagick.app
        }
        $ImageMagick=Get-ChildItem ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles)) "ImageMagick*"|ForEach-Object{
            Get-ChildItem $_.FullName magick.exe
        }|Select-Object -First 1
        if (!(Get-ChocoPackage Ghostscript)){
            choco install Ghostscript
        }
        $ImageMagick
    }
    
    end {
        
    }
}