function Get-NugetPath {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        
    )
    
    begin {
    }
    
    process {
        $nuget = "$env:TEMP\nuget.exe"
        if (!(Test-Path $nuget)) {
            $c = New-Object WebClient
            $c.DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $nuget)
            $c.dispose()
        }
        $nuget
    }
    
    end {
    }
}