function Pop-GitSSH {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [parameter(ParameterSetName = "AddAll")]
        [switch]$AddAll,
        [parameter(ParameterSetName = "AddAll")]
        [string]$Message,
        [switch]$Force,
        [string]$PagentPath = $env:PagentPath,
        [string]$PPKPath = $env:PPKPath,
        [string]$PLinkPath = $env:PLinkPath
    )
    
    begin {
        if (!$PagentPath) {
            throw "PagentPath not valid"
        }
        if (!$PPKPath) {
            throw "PPKPath not valid"
        }
        if (!$PLinkPath) {
            throw "PLinkPath not valid"
        }
        & $PagentPath $PPKPath
        $env:GIT_SSH = $PLinkPath
    }
    
    process {
        git pull 
    }
    
    end {
        
    }
}