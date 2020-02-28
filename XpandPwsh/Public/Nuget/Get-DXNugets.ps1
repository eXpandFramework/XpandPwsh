
function Get-DXNugets {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [parameter(Mandatory)]
        [string]$version
    )
    
    begin {
        
    }
    
    process {
        Write-Verbose "Downloading from https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv"
        (new-object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/eXpandFramework/DevExpress.PackageContent/master/Contents/$version.csv")|ConvertFrom-csv        
    }
    
    end {
        
    }
}
