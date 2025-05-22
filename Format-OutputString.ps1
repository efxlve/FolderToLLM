# Format-OutputString.ps1

function New-FormattedOutput {
    # Function to create the final formatted output string.
    param(
        [string]$RootDirectory,
        [string]$DirectoryStructure,
        [System.Collections.IEnumerable]$FileItems, # Collection of FileInfo objects
        [scriptblock]$ContentReader # Scriptblock to call for reading content, e.g., { Read-SafeTextFileContent -FileItem $_ }
    )

    $outputBuilder = New-Object System.Text.StringBuilder

    [void]$outputBuilder.AppendLine("LLM File Collector Output")
    [void]$outputBuilder.AppendLine("Root Directory: $RootDirectory")
    [void]$outputBuilder.AppendLine("Execution Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$outputBuilder.AppendLine("=" * 50)
    [void]$outputBuilder.AppendLine()
    [void]$outputBuilder.AppendLine("DIRECTORY STRUCTURE:")
    [void]$outputBuilder.AppendLine("-" * 50)
    [void]$outputBuilder.AppendLine($DirectoryStructure)
    [void]$outputBuilder.AppendLine()
    [void]$outputBuilder.AppendLine("=" * 50)
    [void]$outputBuilder.AppendLine("FILE CONTENTS:")
    [void]$outputBuilder.AppendLine("-" * 50)
    [void]$outputBuilder.AppendLine()

    if ($FileItems) {
        foreach ($fileItem in $FileItems) {
            [void]$outputBuilder.AppendLine("--- START: $($fileItem.FullName) ($($fileItem.Length) bytes) ---")
            $content = . $ContentReader -FileItem $fileItem # Invoke the provided scriptblock
            [void]$outputBuilder.AppendLine($content)
            [void]$outputBuilder.AppendLine("--- END: $($fileItem.FullName) ---")
            [void]$outputBuilder.AppendLine()
        }
    } else {
        [void]$outputBuilder.AppendLine("No files matched the criteria or were found.")
    }
    
    return $outputBuilder.ToString()
}

# Removed Export-ModuleMember