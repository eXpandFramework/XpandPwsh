function Invoke-AzureRestMethod {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Resource,
        [string]$Token=$env:AzDevopsToken,
        [string]$Organization=$env:AzOrganization,
        [string]$Project=$env:AzProject,
        [string]$Version = "5.0",
        [object]$Body,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get
    )
    
    begin {
        if (!$Token){
            throw "Token is null"
        }
        if (!$Organization){
            throw "Organization is null"
        }
        if (!$Project){
            throw "Project is null"
        }
    }
    
    process {
        $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$Token"))
        $uri="https://dev.azure.com/$Organization/$Project/_apis/$Resource"
        if ($uri.Contains("*")){
            $uri+="&"
        }
        else{
            $uri+="?"
        }
        $uri+="api-version=$Version"
        $a=@{
            Uri=$uri
            Headers=@{Authorization = "Basic $encodedPat" }
            Method=$Method
        }
        if ($Body){
            $bodyJson = $body | ConvertFrom-Json
            $body = $bodyJson | ConvertTo-Json -Depth 100
            $a.Add("ContentType","application/json")
            $a.Add("Body",$body)
        }
        $resp = Invoke-RestMethod @a
        if ($resp.value){
            $resp.value|ForEach-Object{$_}
        }
        else{
            $resp
        }
    }
    
    end {
    }
}