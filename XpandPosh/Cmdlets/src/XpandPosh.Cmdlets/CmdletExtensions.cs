using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;

namespace XpandPosh.CmdLets{
    static class CmdletExtensions{
        public static string GetCmdletName<T>() where T : Cmdlet{
            var cmdletAttribute = typeof(T).GetCustomAttributes(false).OfType<CmdletAttribute>().First();
            return $"{cmdletAttribute.VerbName}-{cmdletAttribute.NounName}";
        }

        public static T GetVariableValue<T>(this PSCmdlet cmdlet, string name){ 
            return (T)cmdlet.Invoke<PSVariable>($"Get-Variable|where{{$_.Name -eq '{name}'}}").First().Value;
        }

        public static ActionPreference ErrorAction(this PSCmdlet cmdlet){
            if (cmdlet.MyInvocation.BoundParameters.ContainsKey("ErrorAction")){
                return (ActionPreference) cmdlet.MyInvocation.BoundParameters["ErrorAction"];
            }
            return cmdlet.GetVariableValue<ActionPreference>("ErrorActionPreference");
        }

        public static void GetCallerPreference(this Cmdlet cmdlet){
            cmdlet.Invoke("Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState");
        }

        public static Collection<PSObject> Invoke(this Cmdlet cmdlet, string script){
            return cmdlet.Invoke<PSObject>(script);
        }

        public static Collection<T> Invoke<T>(this  Cmdlet cmdlet,string script){
            using (var powerShell = PowerShell.Create(RunspaceMode.CurrentRunspace)){
                powerShell.Commands.AddScript(script);
                return powerShell.Invoke<T>();
            }
        }
    }
}