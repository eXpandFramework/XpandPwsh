namespace XpandPwsh.Cmdlets.Gac{
    internal enum CreateAssemblyNameObjectFlags{
        Default = 0,
        ParseDisplayName = 0x1,
        SetDefaultValues = 0x2,
        VerifyFriendAssemblyName = 0x4,

        ParseFriendDisplayName = ParseDisplayName | VerifyFriendAssemblyName
    }
}