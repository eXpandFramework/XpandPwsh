using System;
using System.Runtime.InteropServices;

namespace XpandPwsh.Cmdlets.Gac{
    [StructLayout(LayoutKind.Sequential)]
    internal class FusionInstallReference{
        private int cbSize;
        private readonly int flags;

        public FusionInstallReference()
            : this(Guid.Empty, null, null){
        }

        public FusionInstallReference(InstallReferenceType type, string identifier, string nonCanonicalData)
            : this(InstallReferenceGuid.FromType(type), identifier, nonCanonicalData){
        }

        public FusionInstallReference(Guid guidScheme, string identifier, string nonCanonicalData){
            var idLength = identifier == null ? 0 : identifier.Length;
            var dataLength = nonCanonicalData == null ? 0 : nonCanonicalData.Length;

            cbSize = 2 * IntPtr.Size + 16 + (idLength + dataLength) * 2;
            flags = 0;
            // quiet compiler warning
            if (flags == 0){
            }

            GuidScheme = guidScheme;
            Identifier = identifier;
            NonCanonicalData = nonCanonicalData;
        }

        public Guid GuidScheme{ get; }

        [field: MarshalAs(UnmanagedType.LPWStr)]
        public string Identifier{ get; }

        [field: MarshalAs(UnmanagedType.LPWStr)]
        public string NonCanonicalData{ get; }
    }
}