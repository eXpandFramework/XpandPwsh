if (!(Get-Module Az -ListAvailable -ErrorAction SilentlyContinue)){
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name Az -AllowClobber -Scope CurrentUser    
}