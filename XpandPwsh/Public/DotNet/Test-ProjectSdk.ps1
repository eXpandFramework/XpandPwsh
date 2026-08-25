function Test-ProjectSdk {
    [CmdletBinding()]
    [CmdLetTag("#visualstudio")]
    param (
        [Parameter(ValueFromPipeline, Mandatory, Position = 0)]
        [Alias("Project", "FullName")] 
        $InputObject
    )

    process {
        # Inner function to check a single project file
        function Test-SingleProject ($projPath) {
            # 1. Validate file existence and extension
            if (-not (Test-Path $projPath -PathType Leaf)) { return $false }
            if ($projPath -notmatch '\.(cs|vb|fs)proj$') { return $false }

            try {
                # 2. Read content
                $content = Get-Content $projPath -Raw
                if ([string]::IsNullOrWhiteSpace($content)) { return $false }
                
                # 3. Quick check for XML structure
                if ($content -notmatch '<Project') { return $false }

                # 4. Parse XML
                [xml]$xml = $content
                
                # Check A: Is it SDK style?
                $isSdk = -not [string]::IsNullOrWhiteSpace($xml.Project.Sdk)
                
                # Check B: Does it use VSSDK? (Requires MSBuild)
                $hasVssdk = $xml.OuterXml -match 'Microsoft\.VSSDK\.BuildTools'
                
                return ($isSdk -and (-not $hasVssdk))
            }
            catch {
                Write-Verbose "Test-ProjectSdk: Skipped '$projPath' (Not a valid SDK project)."
                return $false
            }
        }

        # --- Main Logic ---

        # 1. Resolve Input Path
        $targetPath = if ($InputObject -is [System.IO.FileSystemInfo]) { $InputObject.FullName } else { $InputObject }
        
        # 2. Handle Directory Input: Prefer SLN, then Proj
        if (Test-Path $targetPath -PathType Container) {
            $sln = Get-ChildItem -Path $targetPath -Filter *.sln -File | Select-Object -First 1
            if ($sln) {
                $targetPath = $sln.FullName
            }
            else {
                $proj = Get-ChildItem -Path $targetPath -Filter *.*proj -File | Select-Object -First 1
                if ($proj) { $targetPath = $proj.FullName }
                else { return $false }
            }
        }

        # 3. Handle Solution Files (.sln)
        if ($targetPath -match '\.sln$') {
            try {
                $slnContent = Get-Content $targetPath -Raw
                $slnDir = Split-Path $targetPath -Parent

                # Regex to find project paths inside SLN
                # Format: Project(...) = "Name", "Path.csproj", "GUID"
                $matches = [regex]::Matches($slnContent, 'Project\("{[^}]+}"\) = "[^"]+", "([^"]+\.(cs|vb|fs)proj)",')
                
                if ($matches.Count -eq 0) { return $false }

                foreach ($m in $matches) {
                    $relPath = $m.Groups[1].Value
                    $absPath = Join-Path $slnDir $relPath
                    
                    # If ANY project in the solution requires MSBuild, the whole solution must use MSBuild
                    if (-not (Test-SingleProject $absPath)) {
                        Write-Verbose "Solution requires MSBuild due to: $relPath"
                        return $false
                    }
                }
                # All projects are SDK-style and CLI-compatible
                return $true
            }
            catch {
                Write-Warning "Test-ProjectSdk: Failed to parse Solution '$targetPath'. Defaulting to MSBuild."
                return $false
            }
        }
        # 4. Handle Project Files
        else {
            return Test-SingleProject $targetPath
        }
    }
}