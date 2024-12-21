function Get-AppConfigConnectionString {
    [CmdletBinding(DefaultParameterSetName="File")]
    [CmdLetTag("#dotnet")]
    param (
        [parameter(Mandatory,Position=0)]
        [string]$path,
        [parameter(Mandatory,Position=1)]
        [string]$name
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
    $xmlContent = Get-Content -Path $path -Raw
    $xml = [xml]$xmlContent
    $connectionString = $xml.configuration.connectionStrings.add | 
        Where-Object { $_.name -eq $name } | 
        Select-Object -ExpandProperty connectionString

    if ($connectionString -match "Initial Catalog=([^;]+)") {
        $initialCatalog = $Matches[1]
        Write-Output $initialCatalog
    }        

    }
    
    end {
    }
}