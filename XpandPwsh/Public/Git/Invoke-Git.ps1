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
            $old_env = $env:GIT_REDIRECT_STDERR
            $env:GIT_REDIRECT_STDERR = '2>&1'
    
            Write-Host -ForegroundColor Green "`nExecuting: git $Command "
            $output = Invoke-Expression "git $Command "
            if ( $LASTEXITCODE -gt 0 ) {
                Throw "Error Encountered executing: 'git $Command '"
            }
            else {
                $output | Write-Host 
            }
        }
        finally {
            $env:GIT_REDIRECT_STDERR = $old_env
        }
    }
    
    end {
        
    }
}