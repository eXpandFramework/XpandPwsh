function Format-Xml {
    #.Synopsis
    # Pretty-print formatted XML source
    #.Description
    # Runs an XmlDocument through an auto-indenting XmlWriter
    #.Example
    # [xml]$xml = get-content Data.xml
    # C:\PS>Format-Xml $xml
    #.Example
    # get-content Data.xml | Format-Xml
    #.Example
    # Format-Xml C:\PS\Data.xml -indent 1 -char `t
    # Shows how to convert the indentation to tabs (which can save bytes dramatically, while preserving readability)
    #.Example
    # ls *.xml | Format-Xml
    #
    [CmdletBinding()]
    param(
        # The Xml Document
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Document")]
        $Xml,

        # The path to an xml document (on disc or any other content provider).
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "File")]
        [Alias("PsPath")]
        [string]$Path,

        # The indent level (defaults to 2 spaces)
        [Parameter(Mandatory = $false)]
        [int]$Indent = 2,

        # The indent character (defaults to a space)
        [char]$Character = ' '
    )
    process {
        ## Load from file, if necessary
        if ($Path) { [xml]$xml = Get-Content $Path }

        $StringWriter = New-Object System.IO.StringWriter
        $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
        $xmlWriter.Formatting = "indented"
        $xmlWriter.Indentation = $Indent
        $xmlWriter.IndentChar = $Character
        $xml.WriteContentTo($XmlWriter)
        $XmlWriter.Flush()
        $StringWriter.Flush()
        Write-Output $StringWriter.ToString()
    }
}