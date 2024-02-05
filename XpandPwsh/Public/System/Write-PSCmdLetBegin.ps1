function Write-PSCmdLetBegin {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        $CmdLet
    )
    
    begin {
        
    }
    
    process {
        $cmdletName="$($Cmdlet.CommandRuntime)"
        Write-HostFormatted -object $cmdletName -Stream Verbose -ForegroundColor Blue -style underline
        $defaultParameters="Verbose","Debug","ErrorAction","WarningAction","InformationAction","ErrorVariable","WarningVariable","InformationVariable","OutVariable","OutBuffer","PipelineVariable"
        if ($Cmdlet.MyInvocation.MyCommand.Parameters){
            $commandParameters=$Cmdlet.MyInvocation.MyCommand.Parameters.Keys|Where-Object{$_ -notin $defaultParameters}
            
            $unboundParameters=@($commandParameters|Where-Object{$_ -notin $CmdLet.MyInvocation.BoundParameters.Keys}|Get-Variable -ErrorAction SilentlyContinue|ForEach-Object{
                [PSCustomObject]@{
                    Name = $_.Name
                    Value=$_.Value
                }
            })
            $boundParameters=(@($CmdLet.MyInvocation.BoundParameters.Keys|ForEach-Object{
                [PSCustomObject]@{
                    Name = $_
                    Value=$CmdLet.MyInvocation.BoundParameters[$_]
                }
            }))
            $parameters=($boundParameters+$unboundParameters)
            $parameters|ForEach-Object{
                New-Variable $_.Name $_.Value
                Get-Variable $_.Name|Out-Variable -ForegroundColor Blue
            }
        }
    }
    
    end {
        
    }
}