using System;


namespace XpandPwsh.Cmdlets.Gac{
    [AttributeUsage(AttributeTargets.Assembly | AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class ExtensionAttribute : Attribute{
    }
}