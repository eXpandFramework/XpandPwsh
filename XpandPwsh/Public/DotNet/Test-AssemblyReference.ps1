function Test-AssemblyReference {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [object]$Assembly,
        [parameter(Mandatory)]
        [string]$VersionFilter,
        [string]$ReferenceFilter = "DevEx*"
    )
    
    begin {
        
    }
    
    process {
        if ($Assembly -is [string]) {
            $Assembly=Get-Item $Assembly
        }
        $missMatch = $Assembly | ForEach-Object {
            $refs = Get-AssemblyReference $_.FullName -NameFilter $ReferenceFilter | Where-Object { $_.version -ne $VersionFilter }
            if ($refs) {
                Write-HostFormatted $_.BaseName -Section
                $refs
            }
        }
        $missMatch|ft FullName, Version|Write-Output
        if ($missMatch) {
            throw "Multiple $ReferenceFilter version dependencies"
        }
    }
    
    end {
        
    }
}