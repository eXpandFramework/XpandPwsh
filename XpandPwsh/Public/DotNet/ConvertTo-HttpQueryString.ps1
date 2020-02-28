function ConvertTo-HttpQueryString {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param  (
        [hashtable]$Values=[hashtable]::Empty,
        [string[]]$Variables=@()
    )
 
    Add-Type -AssemblyName System.Web
    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
 
    foreach ($v in $Values.Keys) {
        $value=$Values.$v
        if ($value){
            $nvCollection.Add($v, $value)
        }
    }
    foreach ($v in $Variables) {
        $value=Get-Variable -Name $v 
        if ($value.Value){
            $nvCollection.Add($v, $value.Value)
        }
    }
    $uriRequest = [System.UriBuilder]"http://localhost"
    $uriRequest.Query = $nvCollection.ToString()
    $uriRequest.Uri.Query
}