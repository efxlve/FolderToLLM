# Get-DirectoryStructure.ps1

function Get-DirectoryStructureFormatted {
    # Function to recursively get the directory structure as a formatted string.
    param(
        [string]$Path,
        [string]$Indent = ""
    )

    $childItems = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
    # Separate directories and files and sort them by name for consistent order
    $directories = $childItems | Where-Object {$_.PSIsContainer} | Sort-Object Name
    $files = $childItems | Where-Object {!$_.PSIsContainer} | Sort-Object Name
    
    $outputLines = @() # Use an array to build lines
    
    $totalChildrenCount = $directories.Count + $files.Count
    $processedChildrenCount = 0

    # Process directories
    foreach ($dir in $directories) {
        $processedChildrenCount++
        $isThisChildTheVeryLast = ($processedChildrenCount -eq $totalChildrenCount)
        
        # Determine the prefix for the current directory entry
        $linePrefix = if ($isThisChildTheVeryLast) { "└── " } else { "├── " }
        $outputLines += "$Indent$linePrefix$($dir.Name)" # Removed backtick before $()
        
        # Determine the indent for the children of this directory
        $childIndentContinuation = if ($isThisChildTheVeryLast) { "    " } else { "│   " }
        $recursiveResult = Get-DirectoryStructureFormatted -Path $dir.FullName -Indent ($Indent + $childIndentContinuation)
        
        if (-not [string]::IsNullOrEmpty($recursiveResult)) {
            # Add the multi-line result from recursion to our output lines
            $outputLines += $recursiveResult
        }
    }

    # Process files
    foreach ($file in $files) {
        $processedChildrenCount++
        $isThisChildTheVeryLast = ($processedChildrenCount -eq $totalChildrenCount)
        
        # Determine the prefix for the current file entry
        $linePrefix = if ($isThisChildTheVeryLast) { "└── " } else { "├── " }
        $outputLines += "$Indent$linePrefix$($file.Name)" # Removed backtick before $()
    }

    # Join all collected lines with newlines
    return $outputLines -join "`n"
}