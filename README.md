# FolderToLLM

## Overview

`FolderToLLM` is a PowerShell-based utility for Windows designed to help you gather and consolidate project files into a single text file. This output is particularly useful for providing context to Large Language Models (LLMs) by including the directory structure and the content of selected files.

The script will:
1.  Traverse a specified root directory (defaults to the current directory).
2.  Generate a text representation of the entire directory structure.
3.  Concatenate the content of all (or filtered) files found within that structure.
4.  Offer various filtering options to include/exclude specific folders, file extensions, and files based on size.
5.  Output everything into a timestamped `.txt` file (e.g., `LLM_Output_YYYYMMDDHHMMSS.txt`) in the root directory.

![terminal](https://cdn.goygoyengine.com/images/1747926440007-7ba82bbced04e141.gif)

## Features

*   **Directory Structure Output:** Visual tree-like representation of folders and files.
*   **File Content Aggregation:** Reads and appends the content of each selected file.
*   **Flexible Filtering:**
    *   Include/exclude specific folders (relative to the root path).
    *   Include/exclude specific file extensions (e.g., `.txt`, `.py`).
    *   Include/exclude files based on minimum or maximum size (in bytes).
*   **Default Exclusions:** By default, it excludes:
    *   `node_modules` folder.
    *   `.env` files.
    *   Files larger than 1MB.
    (These defaults can be overridden by command-line arguments).
*   **Safe Content Reading:** Attempts to identify and skip binary files, and truncates very large text files to prevent memory issues.
*   **Easy Execution:** Can be run directly or via a helper batch file for convenient access from any directory.

## Prerequisites

*   Windows Operating System.
*   PowerShell (usually comes pre-installed with Windows).

## Setup and Installation

The easiest way to use `FolderToLLM` from any directory is by using the provided `folderToLLM.bat` helper script and adding its location to your system's PATH environment variable.

1.  **Download/Clone the Repository:**
    Download all the `.ps1` files and the `folderToLLM.bat` file from this repository into a single directory on your computer. For example, you might create a folder like `C:\Tools\FolderToLLM`.

2.  **Configure `folderToLLM.bat`:**
    Open the `folderToLLM.bat` file in a text editor. You **must** update the `MAIN_SCRIPT_PATH` variable to point to the **absolute path** of the `CollectAndPrint.ps1` script in the directory where you placed the files.

    ```batch
    @echo off
    REM MODIFY THIS SECTION CAREFULLY!
    REM Full path to the CollectAndPrint.ps1 script:
    set "MAIN_SCRIPT_PATH=C:\Tools\FolderToLLM\CollectAndPrint.ps1" REM <--- UPDATE THIS PATH

    REM ... rest of the file ...
    ```
    Replace `C:\Tools\FolderToLLM\CollectAndPrint.ps1` with the actual path on your system.

3.  **Add the Script Directory to PATH (Recommended):**
    To run `folderToLLM` from any command line or PowerShell window:
    *   Search for "environment variables" in the Windows search bar and select "Edit the system environment variables."
    *   In the System Properties window, click the "Environment Variables..." button.
    *   Under "System variables" (or "User variables" if you only want it for your account), find the variable named `Path` and select it.
    *   Click "Edit...".
    *   Click "New" and add the path to the directory where you saved `folderToLLM.bat` and the `.ps1` scripts (e.g., `C:\Tools\FolderToLLM`).
    *   Click "OK" on all open dialogs to save the changes.
    *   You might need to **restart any open Command Prompt or PowerShell windows** for the PATH changes to take effect.

4.  **Ensure Script Encoding (Important for Special Characters):**
    All `.ps1` script files (`CollectAndPrint.ps1`, `Get-DirectoryStructure.ps1`, etc.) should be saved with **UTF-8 with BOM** encoding. This is crucial for correctly displaying tree characters and handling various text encodings. Most modern text editors (like VS Code, Notepad++) allow you to save files with this specific encoding.
    *   In VS Code: Click the encoding in the bottom-right status bar, select "Save with Encoding," then choose "UTF-8 with BOM."
    *   In Notepad: "File" > "Save As...", then choose "UTF-8 with BOM" from the "Encoding" dropdown.

## Usage

Once set up, open a Command Prompt or PowerShell window, navigate to the project directory you want to process, and run:

```shell
folderToLLM [arguments]
```

If run without arguments, it will process the current directory with default filters.

### Command-Line Arguments

The `CollectAndPrint.ps1` script (and thus `folderToLLM.bat`) accepts the following optional arguments:

*   `-RootPath <string>`: The root directory to process. Defaults to the current directory.
    *   Example: `folderToLLM -RootPath "C:\Projects\MyWebApp"`
*   `-IncludeFolderPaths <string[]>`: Comma-separated list of relative folder paths to include. If specified, only files within these folders (and their subfolders) will have their content read.
    *   Example: `folderToLLM -IncludeFolderPaths "src", "docs"`
*   `-ExcludeFolderPaths <string[]>`: Comma-separated list of relative folder paths to exclude.
    *   Default: `"node_modules"`
    *   Example: `folderToLLM -ExcludeFolderPaths ".git", "dist", "build"`
*   `-IncludeExtensions <string[]>`: Comma-separated list of file extensions to include (e.g., `.txt`, `.py`, `md`). The leading dot is optional.
    *   Example: `folderToLLM -IncludeExtensions ".js", ".css"`
*   `-ExcludeExtensions <string[]>`: Comma-separated list of file extensions to exclude.
    *   Default: `".env"`
    *   Example: `folderToLLM -ExcludeExtensions ".log", ".tmp", ".bak"`
*   `-MinFileSize <long>`: Minimum file size in bytes. Files smaller than this will be excluded. Use `-1` for no minimum limit.
    *   Example: `folderToLLM -MinFileSize 1024` (exclude files smaller than 1KB)
*   `-MaxFileSize <long>`: Maximum file size in bytes. Files larger than this will be excluded. Use `-1` for no maximum limit.
    *   Default: `1048576` (1MB)
    *   Example: `folderToLLM -MaxFileSize 512000` (exclude files larger than 500KB)
*   `-OutputFileNamePrefix <string>`: Prefix for the generated output file.
    *   Default: `"LLM_Output"`
    *   Example: `folderToLLM -OutputFileNamePrefix "ProjectAlpha_Snapshot"`

### Examples

*   **Process the current directory with default filters:**
    ```shell
    folderToLLM
    ```

*   **Process a specific project, only including `.py` and `.md` files, and excluding the `.venv` folder:**
    ```shell
    folderToLLM -RootPath "D:\MyPythonProject" -IncludeExtensions ".py", ".md" -ExcludeFolderPaths ".venv"
    ```

*   **Process the current directory, excluding files larger than 50KB and also excluding `.zip` files:**
    ```shell
    folderToLLM -MaxFileSize 51200 -ExcludeExtensions ".zip"
    ```

## Script Breakdown

The utility is composed of several small PowerShell scripts, each with a specific responsibility:

*   `CollectAndPrint.ps1`: The main script that orchestrates the process, handles parameters, and calls helper scripts.
*   `folderToLLM.bat`: A batch file wrapper for easy execution of `CollectAndPrint.ps1`.
*   `Get-DirectoryStructure.ps1`: Generates the formatted directory tree string.
*   `Get-FilteredFiles.ps1`: Filters files based on the provided criteria (folders, extensions, size). Contains debug logging that can be uncommented for troubleshooting.
*   `Read-TextFileContent.ps1`: Safely reads the content of text files, with checks for binary files and large files.
*   `Format-OutputString.ps1`: Assembles the final output string, including headers, directory structure, and file contents.

## Troubleshooting

*   **"Failed to load helper scripts..."**:
    *   Ensure all `.ps1` files are in the same directory as `CollectAndPrint.ps1`.
    *   Verify the `MAIN_SCRIPT_PATH` in `folderToLLM.bat` is correct.
*   **Garbled characters in directory structure (e.g., `â””â”€â”€`)**:
    *   Ensure all `.ps1` files are saved with **UTF-8 with BOM** encoding. This is the most common cause.
*   **"The term ... is not recognized as the name of a cmdlet..."**:
    *   This usually means a helper script/function was not loaded correctly. Check file paths and ensure all `.ps1` files are present and correctly encoded.
    *   Restart your PowerShell/Command Prompt window after making changes to scripts or PATH.
*   **Filters not working as expected**:
    *   Uncomment the `Write-Host` debug lines within `Get-FilteredFiles.ps1` to see detailed information about how each file is being processed and why it might be included or excluded.

