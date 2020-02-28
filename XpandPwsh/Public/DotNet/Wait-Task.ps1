function Wait-Task {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        $task
    )
    
    begin {
        
    }
    
    process {
        while (-not $task.AsyncWaitHandle.WaitOne(200)) { }
        $task.GetAwaiter().GetResult()
    }
    
    end {
        
    }
}