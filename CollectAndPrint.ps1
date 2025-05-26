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

#region Parameter Pre-processing for bat file compatibility
# Handle array parameters that might come as a single comma-separated string from cmd.exe via .bat file
if ($IncludeFolderPaths.Count -eq 1 -and $IncludeFolderPaths[0] -match ',') {
    Write-Host "DEBUG: Splitting IncludeFolderPaths from single string: $($IncludeFolderPaths[0])" -ForegroundColor Magenta
    $IncludeFolderPaths = $IncludeFolderPaths[0].Split(',') | ForEach-Object {$_.Trim()} | Where-Object {$_}
}
if ($ExcludeFolderPaths.Count -eq 1 -and $ExcludeFolderPaths[0] -match ',') {
    Write-Host "DEBUG: Splitting ExcludeFolderPaths from single string: $($ExcludeFolderPaths[0])" -ForegroundColor Magenta
    $ExcludeFolderPaths = $ExcludeFolderPaths[0].Split(',') | ForEach-Object {$_.Trim()} | Where-Object {$_}
}
if ($IncludeExtensions.Count -eq 1 -and $IncludeExtensions[0] -match ',') {
    Write-Host "DEBUG: Splitting IncludeExtensions from single string: $($IncludeExtensions[0])" -ForegroundColor Magenta
    $IncludeExtensions = $IncludeExtensions[0].Split(',') | ForEach-Object {$_.Trim()} | Where-Object {$_}
}
if ($ExcludeExtensions.Count -eq 1 -and $ExcludeExtensions[0] -match ',') {
    Write-Host "DEBUG: Splitting ExcludeExtensions from single string: $($ExcludeExtensions[0])" -ForegroundColor Magenta
    $ExcludeExtensions = $ExcludeExtensions[0].Split(',') | ForEach-Object {$_.Trim()} | Where-Object {$_}
}
#endregion

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
Write-Host "Effective IncludeFolderPaths: $($IncludeFolderPaths -join ', ')" # For verification
Write-Host "Effective ExcludeFolderPaths: $($ExcludeFolderPaths -join ', ')"
Write-Host "Effective IncludeExtensions: $($IncludeExtensions -join ', ')"   # For verification
Write-Host "Effective ExcludeExtensions: $($ExcludeExtensions -join ', ')"
Write-Host "Effective MaxFileSize: $MaxFileSize bytes"


# 1. Get Directory Structure
Write-Host "Generating directory structure..."
$directoryStructureString = Get-DirectoryStructureFormatted -Path $RootPath

# 2. Get Filtered Files
Write-Host "Filtering files..."
# Normalize extension filters (ensure they start with a dot and are lowercase)
# This normalization should happen AFTER splitting if they came as a single string
$normalizedIncludeExtensions = @($IncludeExtensions | ForEach-Object { ($_.Trim().ToLowerInvariant() -replace '^\*?(?!\.)','.') } | Where-Object {$_})
$normalizedExcludeExtensions = @($ExcludeExtensions | ForEach-Object { ($_.Trim().ToLowerInvariant() -replace '^\*?(?!\.)','.') } | Where-Object {$_})

Write-Host "Normalized IncludeExtensions: $($normalizedIncludeExtensions -join ', ')"
Write-Host "Normalized ExcludeExtensions: $($normalizedExcludeExtensions -join ', ')"

# Ensure $filteredFileItems is always an array.
# Explicitly pass parameters to Get-FilteredFileItems.
$filteredFileItems = @(Get-FilteredFileItems -RootPath $RootPath `
                                            -IncludeFolders $IncludeFolderPaths `
                                            -ExcludeFolders $ExcludeFolderPaths `
                                            -IncludeExtensions $normalizedIncludeExtensions `
                                            -ExcludeExtensions $normalizedExcludeExtensions `
                                            -MinSize $MinFileSize `
                                            -MaxSize $MaxFileSize)

Write-Host "Found $($filteredFileItems.Count) files matching criteria."

# 3. Format the output (File contents will be read by Format-OutputString via the scriptblock)
Write-Host "Formatting output..."
$finalOutput = New-FormattedOutput -RootDirectory $RootPath `
    -DirectoryStructure $directoryStructureString `
    -FileItems $filteredFileItems `
    -ContentReader { param($FileItem) Read-SafeTextFileContent -FileItem $FileItem }

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
if ((Test-Path $outputFilePath) -and (Get-Item $outputFilePath).Length -lt 20000) {
    Write-Host "`n--- Output File Preview (first 20 lines) ---"
    Get-Content $outputFilePath -TotalCount 20
} elseif (Test-Path $outputFilePath) {
    Write-Host "`nOutput file is large. Preview skipped."
}

Write-Host "Script finished."