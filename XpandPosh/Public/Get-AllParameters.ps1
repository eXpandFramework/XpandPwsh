function Get-AllParameters([System.Management.Automation.InvocationInfo]$invocation,$variables){
    $params=@{}
    foreach($key in $invocation.MyCommand.Parameters.Keys) {
        if (((!$params.ContainsKey($key)))) {
            $variables| ForEach-Object{
                if ($_.Name -eq $key){
                    $params[$key] = $_.Value
                }
            }            
        }
    }
    return $params
}