function Update-AzBuild {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string]$Id,
        [string]$BuildNumber,
        [hashtable]$Parameters,
        [ValidateSet($null, $true, $false)]
        [object]$KeepForEver,
        [ValidateSet($null, $true, $false)]
        [object]$retainedByRelease,
        [string]$Organization = $env:AzOrganization,
        [string]$Project = $env:AzProject,
        [string]$Token = $env:AzDevopsToken
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