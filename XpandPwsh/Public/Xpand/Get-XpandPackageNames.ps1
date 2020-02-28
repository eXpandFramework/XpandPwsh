function Get-XpandPackageNames{
    [CmdLetTag()]
    param(
 
    )
    (((Find-XpandPackage * -PackageSource Release).id|ForEach-Object{
        $_
        # [PSCustomObject]@{
        #     Original = $_
        #     UserFriendly=$_.Replace("eXpand","").Replace("Xpand.XAF.Modules.","").Replace("Xpand.XAF.","").Replace("Xpand.","")
        # }
        
    }))|Sort-Object -Unique
}