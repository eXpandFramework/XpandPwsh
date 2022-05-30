function Resolve-PortUsage {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(ValueFromPipeline,ParameterSetName="port",Mandatory)]
        [int]$Port,
        [ArgumentCompleter( {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
            ((Get-Process).Name | Where-Object { $_ -like "*$wordToComplete*" }).Name
        })]
        [parameter(ValueFromPipeline,ParameterSetName="process",Mandatory)]
        [string]$Processname,
        [switch]$Kill,
        [parameter(ParameterSetName="SystemReserved",Mandatory)]
        [switch]$SystemReserved
    )
    
    begin {
        $PSCmdlet|Write-PSCmdLetBegin
    }
    
    process {
        if ($systemReserved){
            netsh int ipv4 show excludedportrange protocol=tcp
        }
        if ($Processname){
            $id=(Get-Process -Name DXApplication2.Win).Id
            netstat /a /n /o | find " $id"
            return
        }
        $proc=netstat -aon|select-string $Port|ForEach-Object{("$_".substring("$_".LastIndexOf(' '))).Trim()}|ForEach-Object{
            $id=$_
            Get-Process|Where-Object{$_.id -eq $id}
        }
        $proc
        if ($Kill){
            $proc|Stop-Process
        }
    }
    
    end {
        
    }
}