# Read-TextFileContent.ps1

function Read-SafeTextFileContent {
    # Function to safely read text file content.
    # For very large files or binary files, it might return a placeholder or partial content.
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$FileItem,
        [long]$MaxCharsToRead = 1000000 # Limit reading to avoid memory issues with huge files, approx 1MB for UTF-8
    )

    try {
        # Basic check for common binary extensions - can be expanded
        $binaryExtensions = @(".exe", ".dll", ".zip", ".gz", ".tar", ".jpg", ".png", ".gif", ".bmp", ".iso", ".mp3", ".mp4", ".pdf", ".doc", ".xls", ".ppt") # .doc, .xls, .ppt are often binary
        if ($binaryExtensions -contains $FileItem.Extension.ToLowerInvariant()) {
            return "[Binary File: $($FileItem.Name) - Content not displayed]"
        }

        if ($FileItem.Length -eq 0) {
            return "[Empty File: $($FileItem.Name)]"
        }
        
        # Attempt to read as text
        # Using -Raw is faster for reading the whole file
        # We'll use Get-Content with -TotalCount for char limit if necessary
        if ($FileItem.Length -gt ($MaxCharsToRead * 2)) { # Approximation, actual characters depends on encoding
             Write-Warning "File $($FileItem.FullName) is very large ($($FileItem.Length) bytes). Reading up to $MaxCharsToRead characters."
             $content = Get-Content -Path $FileItem.FullName -TotalCount ($MaxCharsToRead / 200) -ErrorAction SilentlyContinue # Approx lines
             # This is a rough way to limit characters, better to read byte stream and decode
             if ($content -is [array]) { $content = $content -join "`n" }
             if ($content.Length -gt $MaxCharsToRead) {
                $content = $content.Substring(0, $MaxCharsToRead) + "... [TRUNCATED]"
             }
             return $content
        } else {
            return Get-Content -Path $FileItem.FullName -Raw -ErrorAction SilentlyContinue
        }
    }
    catch {
        # If Get-Content fails (e.g., encoding issue, locked file)
        return "[Error Reading File: $($FileItem.Name) - $($_.Exception.Message)]"
    }
}

# Removed Export-ModuleMember