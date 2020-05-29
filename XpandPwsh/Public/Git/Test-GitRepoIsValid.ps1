function Test-GitRepoIsValid {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [parameter(ValueFromPipeline)]
        [string]$Path=(Get-Location)
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        git rev-parse --is-inside-work-tree 2>&1 | Out-Null
        if ($LASTEXITCODE){
            $LASTEXITCODE=0
            return $false
        }
        return $true
                
    }
    
    end {
        
    }
}
