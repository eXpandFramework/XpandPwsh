function Submit-GitStage($message) {
    $staged = git diff --name-only --cached
    if ($staged) {
        Write-HostFormatted "Staged files:" -Section
        $staged
        if (!$message){
            $message = Read-Host "Enter Commit message(Enter for default message):"
        }
        $a="-m","$message"
        if (!$message){
            $message="minor update"
            $a+="--amend"
        }
        git commit -m $message 
    }else{
        Write-Warning "Git stage is empty" 
    }
    
}