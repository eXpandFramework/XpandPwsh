function Get-PackageSourceLocations($providerName){
    $(Get-PackageSource|Where-object{
        !$providerName -bor ($_.ProviderName -eq $providerName) 
    }|Select-Object -ExpandProperty Location -Unique|Where-Object{$_ -like "http*" -or (Test-Path $_)})
}