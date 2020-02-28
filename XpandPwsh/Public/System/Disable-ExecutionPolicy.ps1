function Disable-ExecutionPolicy {
    [CmdLetTag()]
    param(

    )
    ($ctx = $executioncontext.gettype().getfield(
        "_context","nonpublic,instance").getvalue(
            $executioncontext)).gettype().getfield(
                "_authorizationManager","nonpublic,instance").setvalue(
        $ctx, (new-object System.Management.Automation.AuthorizationManager `
                  "Microsoft.PowerShell"))
}