function Use-NugetConfig {
    [CmdletBinding()]
    [CmdLetTag("#nuget")]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [parameter(Mandatory)]
        [string[]]$Sources,
        [parameter()]
        [string]$Path="."
    )
    
    begin {
        
    }
    
    process {
        Push-Location ($Path|ConvertTo-Directory).fullname
        try {
            
            for ($i = 0; $i -lt $Sources.Count; $i++) {
                $s=$Sources[$i]
                $key+="<add key=`"$i`" value=`"$s`"/>`r`n"
            }
        $xml=@"
<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <packageSources>
        $key
    </packageSources>
</configuration>
"@
            Set-Content .\Nuget.config $xml
            Invoke-Script{. $ScriptBlock}
        }
        catch {
            throw
        }
        finally {
            Remove-Item .\Nuget.config
            Pop-Location    
        }
        
    }
    
    end {
        
    }
}
