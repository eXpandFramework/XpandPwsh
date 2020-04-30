function Install-ImageMagic {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        
        "imagemagick.app","Ghostscript"|Install-ChocoPackage
        Get-ChildItem ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles)) "ImageMagick*"|ForEach-Object{
            Get-ChildItem $_.FullName magick.exe
        }|Select-Object -First 1
    }
    
    end {
        
    }
}