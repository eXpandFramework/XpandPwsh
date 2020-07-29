function New-Image {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory)]
        [int]$Width,
        [parameter(Mandatory)]
        [int]$Height,
        [parameter()]
        [System.Drawing.Color]$Color=([System.Drawing.Color]::White),
        [parameter()]
        [System.Drawing.Imaging.ImageFormat]$ImageFormat=[System.Drawing.Imaging.ImageFormat]::Png,
        [parameter()]
        [string]$OutputBaseName="image",
        [parameter()]
        [string]$OutputDirectory=(Get-Location)

    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        
    }
    
    process {
        Use-Object($bmp=[System.Drawing.Bitmap]::new($Width,$Height)){
            Use-Object($g=[System.Drawing.Graphics]::FromImage($bmp)){
                $g.Clear($Color)
            }
            $bmp.Save("$OutputDirectory\$OutputBaseName.$ImageFormat",$ImageFormat)
        }
        Get-Item "$OutputDirectory\$OutputBaseName.$ImageFormat"
    }
    
    end {
        
    }
}