function Test-SqlConnection {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$userName,
        [Parameter(Mandatory)]
        [string]$pass
    )
`   
    $ErrorActionPreference = 'Stop'

    try {
        
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$pass
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        $true
    } catch {
        Write-Verbose $_
        $false
    } finally {

        $sqlConnection.Close()
    }
}