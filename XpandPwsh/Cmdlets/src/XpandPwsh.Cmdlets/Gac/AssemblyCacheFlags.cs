using System;

namespace XpandPwsh.Cmdlets.Gac{
    [Flags]
    internal enum AssemblyCacheFlags{
        Zap = 0x1,
        Gac = 0x2,
        Download = 0x4,
        Root = 0x8,
        RootEx = 0x80
    }
}