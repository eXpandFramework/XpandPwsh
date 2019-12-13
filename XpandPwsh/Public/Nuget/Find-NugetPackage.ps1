function Find-NugetPackage {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$Name,
        [switch]$AllVersions,
        [int]$Skip,
        [int]$Take,
        [switch]$Prelease,
        [switch]$OriginalFormat
    )
    
    begin {
        
    }
    
    process {
        $q = ConvertTo-HttpQueryString @{
            q = $name
            skip=$Skip
            take=$Take
            Prelease=$Prelease.IsPresent
        }
        (Invoke-RestMethod "https://azuresearch-usnc.nuget.org/query$q").data|ForEach-Object{
            if (!$OriginalFormat){
                [PSCustomObject]@{
                    Id = $_.id
                    Version=$_.Version
                }
            }
            else{
                $_
            }
        }
    }
    
    end {
        
    }
}