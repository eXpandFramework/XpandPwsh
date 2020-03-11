using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace XpandPwsh.Cmdlets.Gac{
    internal static class FusionApi{
        static FusionApi(){
            
            
            Initialize(@$"{Environment.GetFolderPath(Environment.SpecialFolder.Windows)}\Microsoft.NET\Framework\v4.0.30319");
        }

        internal static CreateAssemblyEnumMethod CreateAssemblyEnum{ get; private set; }

        internal static CreateAssemblyNameObjectMethod CreateAssemblyNameObject{ get; private set; }

        internal static CreateAssemblyCacheMethod CreateAssemblyCache{ get; private set; }

        internal static CreateInstallReferenceEnumMethod CreateInstallReferenceEnum{ get; private set; }

        internal static GetCachePathMethod GetCachePath{ get; private set; }


        private static void Initialize(string path){
            var dll = Win32Check(NativeMethods.LoadLibrary(Path.Combine(path, "fusion.dll")));

            CreateAssemblyEnum = ImportNativeMethod<CreateAssemblyEnumMethod>(dll, "CreateAssemblyEnum");
            CreateAssemblyNameObject =
                ImportNativeMethod<CreateAssemblyNameObjectMethod>(dll, "CreateAssemblyNameObject");
            CreateAssemblyCache = ImportNativeMethod<CreateAssemblyCacheMethod>(dll, "CreateAssemblyCache");
            CreateInstallReferenceEnum =
                ImportNativeMethod<CreateInstallReferenceEnumMethod>(dll, "CreateInstallReferenceEnum");
            GetCachePath = ImportNativeMethod<GetCachePathMethod>(dll, "GetCachePath");
        }

        private static IntPtr Win32Check(IntPtr result){
            if (result == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error());

            return result;
        }

        private static T ImportNativeMethod<T>(IntPtr dll, string name) where T : class{
            var function = Win32Check(NativeMethods.GetProcAddress(dll, name));
            return Marshal.GetDelegateForFunctionPointer(function, typeof(T)) as T;
        }

        [UnmanagedFunctionPointer(CallingConvention.Winapi, CharSet = CharSet.Unicode)]
        internal delegate int CreateAssemblyEnumMethod(
            out IAssemblyEnum ppEnum,
            IntPtr pUnkReserved,
            IAssemblyName pName,
            AssemblyCacheFlags flags,
            IntPtr pvReserved);

        [UnmanagedFunctionPointer(CallingConvention.Winapi, CharSet = CharSet.Unicode)]
        internal delegate int CreateAssemblyNameObjectMethod(
            out IAssemblyName ppAssemblyNameObj,
            [MarshalAs(UnmanagedType.LPWStr)] string szAssemblyName,
            CreateAssemblyNameObjectFlags flags,
            IntPtr pvReserved);

        [UnmanagedFunctionPointer(CallingConvention.Winapi, CharSet = CharSet.Unicode)]
        internal delegate int CreateAssemblyCacheMethod(
            out IAssemblyCache ppAsmCache,
            int reserved);

        [UnmanagedFunctionPointer(CallingConvention.Winapi, CharSet = CharSet.Unicode)]
        internal delegate int CreateInstallReferenceEnumMethod(
            out IInstallReferenceEnum ppRefEnum,
            IAssemblyName pName,
            int dwFlags,
            IntPtr pvReserved);

        [UnmanagedFunctionPointer(CallingConvention.Winapi, CharSet = CharSet.Unicode)]
        internal delegate int GetCachePathMethod(
            AssemblyCacheFlags assemblyCacheFlags,
            [MarshalAs(UnmanagedType.LPWStr)] StringBuilder cachePath,
            ref int cachePathSize);
    }
}