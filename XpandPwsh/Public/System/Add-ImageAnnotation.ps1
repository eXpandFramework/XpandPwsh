function Add-ImageAnnotation {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo]$Image,
        [parameter(Mandatory,ParameterSetName="text")]
        [string]$Text,
        [parameter(Mandatory,ParameterSetName="overlay")]
        [string]$ImageOverlay,
        $Color="blue",
        $Gravity="center",
        [int]$PointSize=48
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
        $ImageMagick=Install-ImageMagic
    }
    
    process {
        Push-Location $Image.DirectoryName
        
        if ($Text){
            & $ImageMagick $Image -pointsize $PointSize -fill $Color label:$Text -gravity $Gravity -append "$($Image.BaseName)_$($image.Extension)"
        }
        else{
            & $ImageMagick composite -gravity $Gravity  $ImageOverlay  $Image.FullName  "$($Image.BaseName)_$($image.Extension)"
        }
        
        Remove-Item "$($Image.BaseName)$($image.Extension)"
        Rename-Item "$($Image.BaseName)_$($image.Extension)" "$($Image.BaseName)$($image.Extension)" -Force
        Pop-Location
    }
    
    end {
        
    }
}