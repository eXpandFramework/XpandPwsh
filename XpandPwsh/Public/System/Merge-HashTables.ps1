function Merge-HashTables {
    [CmdletBinding()]
    [CmdLetTag()]
    param (
        [scriptblock]$Operator
    )
    
    begin {
        
    }
    
    process {
        $Output = @{}
        ForEach ($Hashtable in $Input) {
            If ($Hashtable -is [Hashtable]) {
                ForEach ($Key in $Hashtable.Keys) {$Output.$Key = If ($Output.ContainsKey($Key)) {@($Output.$Key) + $Hashtable.$Key} Else  {$Hashtable.$Key}}
            }
        }
        If ($Operator) {ForEach ($Key in @($Output.Keys)) {$_ = @($Output.$Key); $Output.$Key = Invoke-Command $Operator}}
        $Output
    }
    
    end {
        
    }
}