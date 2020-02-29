function Get-XpandPackageHome {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        [string]$Id,
        [version]$Version
    )
    
    begin {
        
    }
    
    process {
        $homePage=$null
        if ($Id -like "Xpand.Extensions*"){
            $homePage="https://github.com/eXpandFramework/DevExpress.XAF/tree/master/src/Extensions/$Id"
        }
        elseif ($Id -like "Xpand.XAF.Modules*"){
            $homePage="https://github.com/eXpandFramework/DevExpress.XAF/tree/master/src/Modules/$($id.Replace('Xpand.XAF.Modules.',''))"
        }
        elseif ($Id -like "*.All.*"){
            $homePage="https://github.com/eXpandFramework/DevExpress.XAF/tree/master/src/Modules"
        }
        elseif ($Id -like "*VersionConverter*"){
            $homePage="https://github.com/eXpandFramework/DevExpress.XAF/tree/master/tools/Xpand.VersionConverter"
        }
        elseif ($Id -like "*ModelEditor*"){
            $homePage="https://github.com/eXpandFramework/DevExpress.XAF/tree/master/tools/Xpand.XAF.ModelEditor"
        }
        else {
            throw $Id
        }
        if ($]$Version){
            $homePage="[$Id v.$Version]($homePage)"
        }
        $homePage
    }
    
    end {
        
    }
}