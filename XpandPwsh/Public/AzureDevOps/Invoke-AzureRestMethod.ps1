function Invoke-AzureRestMethod {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Token,
        [parameter(Mandatory)]
        [string]$Organization,
        [parameter(Mandatory)]
        [string]$Project,
        [parameter(Mandatory)]
        [string]$Resource,
        [string]$Version = "5.0",
        [object]$Body
    )
    
    begin {
    }
    
    process {
        $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$Token"))
        $uri="https://dev.azure.com/$Organization/$Project/_apis/$Resource`?api-version=$Version"
        $resp = Invoke-RestMethod -Uri $uri -Headers @{Authorization = "Basic $encodedPat" } -Body $Body 
        $resp.value|ForEach-Object{$_}
    }
    
    end {
    }
}