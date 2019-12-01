function Submit-GitStage($message) {
    $staged = git diff --name-only --cached
    if ($staged) {
        Write-HostFormatted "Staged files:" -Section
        $staged
        if (!$message){
            $message = Read-Host "Enter Commit message(Enter for default message):"
        }
        if (!$message){
            $message="minor update"
        }
        git commit -m $message
    }else{
        Write-Error "Git stage is empty" 
    }
    
}