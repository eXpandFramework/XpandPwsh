namespace XpandPwsh.Cmdlets.Gac{
    internal enum AssemblyCacheUninstallDisposition{
        Unknown = 0,
        Uninstalled = 1,
        StillInUse = 2,
        AlreadyUninstalled = 3,
        DeletePending = 4,
        HasInstallReference = 5,
        ReferenceNotFound = 6
    }
}