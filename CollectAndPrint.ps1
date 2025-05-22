# CollectAndPrint.ps1 - Main script to collect directory structure and file contents.

[CmdletBinding()]
param(
    # Default root path to the current directory where the script is run.
    [string]$RootPath = (Get-Location).Path,

    # Folders to include. If specified, only files in these folders (and subfolders) are processed.
    [string[]]$IncludeFolderPaths = @(),

    # Folders to exclude. Default to "node_modules". User can override or add more.
    [string[]]$ExcludeFolderPaths = @("node_modules"), # Default exclusion

    # File extensions to include. If specified, only files with these extensions are processed.
    [string[]]$IncludeExtensions = @(),

    # File extensions to exclude. Default to ".env". User can override or add more.
    [string[]]$ExcludeExtensions = @(".env"), # Default exclusion

    # Minimum file size in bytes. -1 for no limit.
    [long]$MinFileSize = -1,

    # Maximum file size in bytes. Default to 1MB (1024 * 1024 bytes). -1 for no limit.
    [long]$MaxFileSize = 1048576, # Default max size: 1MB
    
    # Prefix for the output file name.
    [string]$OutputFileNamePrefix = "LLM_Output"
)

# Dot-source the helper scripts to make their functions available.
# Ensure these .ps1 files are in the same directory as this script, or provide full paths.
try {
    . "$PSScriptRoot\Get-DirectoryStructure.ps1"
    . "$PSScriptRoot\Get-FilteredFiles.ps1"
    . "$PSScriptRoot\Read-TextFileContent.ps1"
    . "$PSScriptRoot\Format-OutputString.ps1"
}
catch {
    Write-Error "Failed to load helper scripts. Ensure they are in the same directory: $PSScriptRoot. Error: $($_.Exception.Message)"
    exit 1
}

Write-Host "Processing directory: $RootPath"
Write-Host "Effective ExcludeFolderPaths: $($ExcludeFolderPaths -join ', ')"
Write-Host "Effective ExcludeExtensions: $($ExcludeExtensions -join ', ')" # This is from CollectAndPrint's scope
Write-Host "Effective MaxFileSize: $MaxFileSize bytes" # This is from CollectAndPrint's scope


# 1. Get Directory Structure
Write-Host "Generating directory structure..."
$directoryStructureString = Get-DirectoryStructureFormatted -Path $RootPath

# 2. Get Filtered Files
Write-Host "Filtering files..."
# Normalize extension filters (ensure they start with a dot and are lowercase)
$normalizedIncludeExtensions = @($IncludeExtensions | ForEach-Object { ($_.ToLowerInvariant() -replace '^\*?(?!\.)','.') })
$normalizedExcludeExtensions = @($ExcludeExtensions | ForEach-Object { ($_.ToLowerInvariant() -replace '^\*?(?!\.)','.') })

# Ensure $filteredFileItems is always an array.
# Explicitly pass parameters to Get-FilteredFileItems.
$filteredFileItems = @(Get-FilteredFileItems -RootPath $RootPath `
                                            -IncludeFolders $IncludeFolderPaths `
                                            -ExcludeFolders $ExcludeFolderPaths `
                                            -IncludeExtensions $normalizedIncludeExtensions `
                                            -ExcludeExtensions $normalizedExcludeExtensions `
                                            -MinSize $MinFileSize `
                                            -MaxSize $MaxFileSize) # This is the MaxFileSize from CollectAndPrint's param block

Write-Host "Found $($filteredFileItems.Count) files matching criteria."

# 3. Format the output (File contents will be read by Format-OutputString via the scriptblock)
Write-Host "Formatting output..."
$finalOutput = New-FormattedOutput -RootDirectory $RootPath `
    -DirectoryStructure $directoryStructureString `
    -FileItems $filteredFileItems `
    -ContentReader { param($FileItem) Read-SafeTextFileContent -FileItem $FileItem } # Pass our reader function

# 4. Output to File
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$outputFilePath = Join-Path -Path $RootPath -ChildPath "$($OutputFileNamePrefix)_$timestamp.txt"

try {
    Write-Host "Writing output to: $outputFilePath"
    $finalOutput | Out-File -FilePath $outputFilePath -Encoding UTF8 -Force
    Write-Host "Successfully generated output file."
}
catch {
    Write-Error "Failed to write output file: $($_.Exception.Message)"
}

# Optional: Display a snippet or confirmation
if ((Test-Path $outputFilePath) -and (Get-Item $outputFilePath).Length -lt 20000) { # If file is small enough
    Write-Host "`n--- Output File Preview (first 20 lines) ---"
    Get-Content $outputFilePath -TotalCount 20
} elseif (Test-Path $outputFilePath) {
    Write-Host "`nOutput file is large. Preview skipped."
}

Write-Host "Script finished."