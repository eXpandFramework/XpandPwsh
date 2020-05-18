if (!(Get-Module Az -ListAvailable -ErrorAction SilentlyContinue)){
    if (!(Get-PSRepository|Select-String PSGallery )){
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    Install-Module -Name Az -AllowClobber -Scope CurrentUser    
}