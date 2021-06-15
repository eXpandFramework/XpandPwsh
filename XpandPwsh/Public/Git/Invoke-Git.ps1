function Invoke-Git {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [Parameter(Mandatory)]
        [string] $Command
    )
    
    begin {
        $PSCmdlet | Write-PSCmdLetBegin
    }
    
    process {
        try {

            $exit = 0
            $path = [System.IO.Path]::GetTempFileName()
    
            Invoke-Expression "git $Command 2> $path"
            $exit = $LASTEXITCODE
            if ( $exit -gt 0 ) {
                Write-Error (Get-Content $path).ToString()
            }
            else {
                Get-Content $path | Select-Object -First 1
            }
            $exit
        }
        catch {
            Write-Host "Error: $_`n$($_.ScriptStackTrace)"
        }
        finally {
            if ( Test-Path $path ) {
                Remove-Item $path
            }
        }
    }
    
    end {
        
    }
}