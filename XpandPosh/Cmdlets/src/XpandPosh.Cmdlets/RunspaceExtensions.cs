using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace XpandPosh.Cmdlets{
    internal static class RunspaceExtensions{
        public static Collection<PSObject> Invoke(this Runspace runspace, string script){
            using (var powerShell = PowerShell.Create()){
                powerShell.Runspace=runspace;
                return powerShell.AddScript(script).Invoke();
            }
        }

        public static void SetVariable(this Runspace runspace, params PSVariable[] psVariables){
            using (var powerShell = PowerShell.Create()){
                powerShell.Runspace=runspace;
                foreach (var variable in psVariables.Where(variable => !new[]{ScopedItemOptions.Constant,ScopedItemOptions.ReadOnly }.Contains(variable.Options))){
                    try{
                        powerShell.AddCommand("Set-Variable").AddParameter("Name",variable.Name).AddParameter("Value",variable.Value).Invoke();
                    }
                    catch (ActionPreferenceStopException){

                    }
                }
                
            }
        }

    }
}