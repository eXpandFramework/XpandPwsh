function Test-ProjectSdk {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [xml]$Project
    )
    
    begin {
        
    }
    
    process {
        $Project.Project.Sdk -eq "Microsoft.NET.Sdk"
    }
    
    end {
        
    }
}