function Invoke-AzureRestMethod {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(Mandatory)]
        [string]$Resource,
        [parameter()][string]$Token=$env:AzureToken,
        [parameter()][string]$Organization=$env:AzOrganization,
        [parameter()][string]$Project=$env:AzProject,
        [parameter()][string]$Version = "5.1",
        [parameter()][object]$Body,
        [parameter()][Microsoft.PowerShell.Commands.WebRequestMethod]$Method=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get
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
        if ($Project -eq "AzDevOpsProjectRestApi"){
            $Project=$null
        }
        . $XpandPwshPath\Private\InstallAz.ps1
    }
    
    process {
        $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$Token"))
        $uri="https://dev.azure.com/$Organization"
        if ($Project){
            $uri+="/$Project"
        }
        $uri+="/_apis/$Resource"
        if ($uri.Contains("*") -or $uri.Contains("?")){
            $uri+="&"
        }
        elseif (!$uri.Contains("?")){
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
        if ($resp.value -is [array]){
            $resp.value|ForEach-Object{$_}
        }
        else{
            $resp
        }
    }
    
    end {
    }
}