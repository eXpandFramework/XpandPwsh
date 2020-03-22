function Use-Object {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]$InputObject,
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock
    )   

    try {
        . $ScriptBlock
    }
    catch {
        throw 
    }
    finally {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable]) {
            $InputObject.Dispose()|Out-Null
        }
    }
}