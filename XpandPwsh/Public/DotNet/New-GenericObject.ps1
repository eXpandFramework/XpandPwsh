function New-GenericObject {
    [CmdletBinding()]
    [CmdLetTag("#dotnet")]
    param (
        [parameter()]
        [string] $typeName,
        [parameter()]
        [string[]] $typeParameters = "System.Object",
        [parameter()]
        [object[]] $constructorParameters,
        [parameter()]
        [ValidateSet("Collection","Dictionary","DictionaryOfLists","StringDictionary")]
        [string]$PredifinedType
    )
    
    begin {
        
    }
    
    process {
        if ($PredifinedType -eq "Collection"){
            $typeName="System.Collections.ObjectModel.Collection"
        }
        elseif ($PredifinedType -eq "Collection"){
            $typeName=System.Collections.Generic.Dictionary 
            $typeParameters+="System.Object"
        }
        elseif ($PredifinedType -eq "DictionaryOfLists"){
            $secondType = New-GenericObject -predifinedType Collection
            return New-GenericObject System.Collections.Generic.Dictionary System.Object,$secondType.GetType()
        }
        elseif ($PredifinedType -eq "StringDictionary"){
            return New-GenericObject System.Collections.Generic.Dictionary System.String,System.String
        }
        $genericTypeName = $typeName + '`' + $typeParameters.Count
        $genericType = [Type] $genericTypeName

        if(-not $genericType)        {
            throw "Could not find generic type $genericTypeName"
        }
        [type[]] $typedParameters = $typeParameters
        $closedType = $genericType.MakeGenericType($typedParameters)
        if(-not $closedType)        {
            throw "Could not make closed type $genericType"
        }

        ,[Activator]::CreateInstance($closedType, $constructorParameters)
    }
    end {
        
    }
}