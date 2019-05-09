function Publish-AssemblyToGac {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, Mandatory)]
        $assembly
    )
    
    begin {
        [System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")|Out-Null
        $publish = New-Object System.EnterpriseServices.Internal.Publish
    }
    
    process {
        $publish.GacInstall($assembly)
        "$assembly published"
    }
    
    end {
    }
}