function Get-PackageSourceLocations {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [parameter()][string]$ProviderName,
        [parameter()][string]$Name,
        [parameter()][Switch]$AllTypes
    )
    
    begin {
        if ($Name -in (Get-PackageSource).Name ) {
            $Name = Get-PackageSourceLocations -Name $Name
        }
    }
    
    process {
        $(Get-PackageSource|Where-object{
            (($providerName -and $_.ProviderName -eq $providerName) -or ($Name -and $_.Name -eq $Name))
        }|Select-Object -ExpandProperty Location -Unique|Where-Object{
            if (!$AllTypes){
                $_ -like "http*" -or (Test-Path $_)
            }
        })       
    }
    
    end {
        
    }
}