function Invoke-NugetPack {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [parameter(Mandatory)]
        [string]$Nuspec,
        [string]$OutputDirectory=$PSScriptRoot,
        [string]$Basepath=$OutputDirectory
    )
    
    begin {
        
    }
    
    process {
        $nuspecFileName=(Get-Item $Nuspec).FullName
        $output=Invoke-Script{
            (& (Get-NugetPath) pack $nuspecFileName -OutputDirectory "$OutputDirectory" -BasePath "$Basepath")
        }
        $regex = [regex] '(?is)''(.*)\.nupkg'''
        $result = $regex.Match($output[1]).Groups[1].Value;
        if ($result){
            Get-Item "$result.nupkg"
        }
        else{
            Write-Output $output
        }
        
    }
    
    end {
    }
}

