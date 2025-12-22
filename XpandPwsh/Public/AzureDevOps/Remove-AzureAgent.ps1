function Remove-AzureAgent{
    param(
        [parameter(Mandatory)]
        $token,
        [parameter(Mandatory)]
        $organization,
        [parameter(Mandatory)]
        $newVMName,
        [parameter(Mandatory)]
        $agentPool
    )
    $headers = @{
        Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$token"))
    }
    
    # 1. Get Pool ID
    $apiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools?api-version=6.0"
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
    $poolId = $response.value | Where-Object { $_.name -eq $agentPool } | Select-Object -ExpandProperty id
    
    # 2. Get Agent ID
    $apiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents?api-version=6.0"
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
    $agents = $response.value
    $agentId = $agents | Where-Object { $_.name -eq $newVMName } | Select-Object -ExpandProperty id
    
    # 3. Delete
    if ($agentId){
        $apiUrl = "https://dev.azure.com/{0}/_apis/distributedtask/pools/{1}/agents/{2}?api-version=6.0" -f $organization, $poolId, $agentId
        Invoke-RestMethod -Uri $apiUrl -Method Delete -Headers $headers
        Write-Host "Agent $newVMName removed."
    }
}