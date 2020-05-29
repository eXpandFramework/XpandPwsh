function Invoke-NugetPack {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo[]]$Nuspec,
        [string]$OutputDirectory=$Nuspec.DirectoryName,
        [string]$Basepath=$OutputDirectory
    )
    
    begin {
        
    }
    
    process {
        Invoke-Script{
            
            & (Get-NugetPath) pack "$($Nuspec.FullName)" -OutputDirectory "$OutputDirectory" -BasePath "$Basepath"
        }
    }
    
    end {
    }
}

