using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;

namespace XpandPwsh.CmdLets{
    static class CmdletExtensions{
        public static string GetCmdletName(Type type) {
            var cmdletAttribute = type.GetCustomAttributes(false).OfType<CmdletAttribute>().First();
            return $"{cmdletAttribute.VerbName}-{cmdletAttribute.NounName}";
        }

        public static string GetCmdletName<T>() where T : Cmdlet{
            return GetCmdletName(typeof(T));
        }

        public static T GetVariableValue<T>(this PSCmdlet cmdlet, string name){
            var psVariable = cmdlet.Invoke<PSVariable>($"Get-Variable|where{{$_.Name -eq '{name}'}}").FirstOrDefault();
            if (psVariable==null)
                throw new NullReferenceException(name);
            if (typeof(T).IsEnum)
                return (T) Enum.Parse(typeof(T),psVariable.Value.ToString(),true);
            return (T)psVariable.Value;
        }

        public static ActionPreference ErrorAction(this PSCmdlet cmdlet){
            if (cmdlet.MyInvocation.BoundParameters.ContainsKey("ErrorAction")){
                return (ActionPreference) cmdlet.MyInvocation.BoundParameters["ErrorAction"];
            }
            return cmdlet.GetVariableValue<ActionPreference>("ErrorActionPreference");
        }

        public static void GetCallerPreference(this PSCmdlet cmdlet){
            // cmdlet.Invoke("Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState");
        }

        public static Collection<PSObject> Invoke(this Cmdlet cmdlet, string script,RunspaceMode  runspaceMode=RunspaceMode.CurrentRunspace){
            return cmdlet.Invoke<PSObject>(script,runspaceMode);
        }

        public static Collection<T> Invoke<T>(this  Cmdlet cmdlet,string script,RunspaceMode  runspaceMode=RunspaceMode.CurrentRunspace){
            using (var powerShell = PowerShell.Create(runspaceMode)){
                powerShell.Commands.AddScript(script);
                powerShell.AddParameter("PSCmdLet", cmdlet);
                return powerShell.Invoke<T>();
            }
        }
    }
}