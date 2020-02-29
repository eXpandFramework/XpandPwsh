function Get-XpandPackageHome {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id
    )
    
    begin {
        
    }
    
    process {
        if ($Id -like "Xpand.Extensions"){
            "https://github.com/eXpandFramework/DevExpress.XAF/tree/master/src/Extensions/$Id"
        }
        elseif ($Id -like "Xpand.XAF.Modules"){
            "https://github.com/eXpandFramework/DevExpress.XAF/tree/master/src/Modules/$($id.Replace('Xpand.XAF.Modules.',''))"
        }
    }
    
    end {
        
    }
}