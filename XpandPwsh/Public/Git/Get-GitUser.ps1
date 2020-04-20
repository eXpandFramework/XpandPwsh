function Get-GitUser {
    [CmdletBinding()]
    [CmdLetTag("#git")]
    param(
        
    )
    
    begin {
        
    }
    
    process {
        
        $userName=git config --list | ForEach-Object{
            $items=$_.Split("=")
            if ($items[0] -eq "user.name"){
                $items[1]
            }
        }
        $userMail=git config --list | ForEach-Object{
            $items=$_.Split("=")
            if ($items[0] -eq "user.mail"){
                $items[1]
            }
        }
        if ($userName){
            [PSCustomObject]@{
                Name = $userName
                Email=$userMail
            }
        }
        
    }
    
    end {
        Pop-Location
    }
}