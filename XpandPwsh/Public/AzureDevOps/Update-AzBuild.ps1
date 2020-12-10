function Update-AzBuild {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","#AzureDevOps"))]
    param (
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Id,
        [parameter()][string]$BuildNumber,
        [parameter()][hashtable]$Parameters,
        [ValidateSet($null, $true, $false)]
        [parameter()][object]$KeepForEver,
        [ValidateSet($null, $true, $false)]
        [parameter()][object]$retainedByRelease,
        [parameter()][string]$Organization = $env:AzOrganization,
        [parameter()][string]$Project = $env:AzProject,
        [parameter()][string]$Token = $env:AzureToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }   
    }
    
    process {
        $body = @{
            parameters        = $Parameters | ConvertTo-Json
            buildNumber       = $BuildNumber
            keepForever       = $KeepForEver
            retainedByRelease = $retainedByRelease
        } | Remove-DefaultValueKeys 
        
        Invoke-AzureRestMethod "build/builds/$Id" -Method Patch -Body ($body | ConvertTo-Json) @cred
    }
    end {
        
    }
}