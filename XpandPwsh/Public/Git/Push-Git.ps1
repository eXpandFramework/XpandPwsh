function Push-Git {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param (
        [parameter(ParameterSetName = "AddAll")]
        [switch]$AddAll,
        [parameter(ParameterSetName = "AddAll")]
        [string]$Message,
        [string]$Remote="origin",
        [string]$Username,
        [string]$UserMail,
        [switch]$Force
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        if (!(Get-GitUser) -and $username){
            git config user.email $userMail
            git config user.name $userName
        }
        Invoke-Script{
            if ($AddAll) {
                git add -A
                if ($message) {
                    git commit -m $message
                }
                else {
                    git commit --amend  --no-edit
                }
            }
        }
        Invoke-Script{
            $a=@()
            if ($Force){
                $a+="-f"
            }
            git push @a
        }
    }
    
    end {
        
    }
}