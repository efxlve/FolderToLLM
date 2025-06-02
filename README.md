# FolderToLLM - Mac Version

## Overview

`FolderToLLM` for Mac is a shell script-based utility designed to help you gather and consolidate project files into a single text file. This output is particularly useful for providing context to Large Language Models (LLMs) by including the directory structure and the content of selected files.

This is a Mac-compatible adaptation of the original Windows PowerShell version, providing the same functionality using bash/shell scripts that work natively on macOS and Linux systems.

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
    *   Binary files (automatically detected).
*   **Safe Content Reading:** Automatically identifies and skips binary files, and truncates very large text files to prevent memory issues.
*   **Native macOS Support:** Works with the default bash/zsh shell on macOS without requiring additional software.

## Prerequisites

*   macOS or Linux operating system
*   Bash shell (pre-installed on macOS)
*   Standard Unix utilities: `find`, `stat`, `file`, `head`, `cat` (pre-installed on macOS)

## Installation and Setup

### Option 1: Local Installation (Recommended)

1. **Download the Scripts:**
   Clone or download all the `.sh` files into a single directory:
   ```bash
   mkdir ~/FolderToLLM
   cd ~/FolderToLLM
   # Place all .sh files here
   ```

2. **Make Scripts Executable:**
   ```bash
   chmod +x *.sh
   ```

3. **Test the Installation:**
   ```bash
   ./folderToLLM.sh --help
   ```

### Option 2: Global Installation (Advanced)

1. **Move to a System Directory:**
   ```bash
   sudo mkdir -p /usr/local/bin/folderToLLM
   sudo cp *.sh /usr/local/bin/folderToLLM/
   sudo chmod +x /usr/local/bin/folderToLLM/*.sh
   ```

2. **Create a Symlink:**
   ```bash
   sudo ln -sf /usr/local/bin/folderToLLM/folderToLLM.sh /usr/local/bin/folderToLLM
   ```

3. **Use from Anywhere:**
   ```bash
   folderToLLM --help
   ```

## Usage

Navigate to the project directory you want to process and run:

```bash
./folderToLLM.sh [OPTIONS]
```

If you've installed it globally:
```bash
folderToLLM [OPTIONS]
```

### Command-Line Options

| Option | Long Option | Description | Default |
|--------|-------------|-------------|---------|
| `-r` | `--root-path` | Root directory to process | Current directory |
| `-if` | `--include-folders` | Comma-separated list of folders to include | None |
| `-ef` | `--exclude-folders` | Comma-separated list of folders to exclude | `node_modules` |
| `-ie` | `--include-extensions` | Comma-separated list of extensions to include | None |
| `-ee` | `--exclude-extensions` | Comma-separated list of extensions to exclude | `.env` |
| `-min` | `--min-file-size` | Minimum file size in bytes | No limit |
| `-max` | `--max-file-size` | Maximum file size in bytes | 1048576 (1MB) |
| `-p` | `--prefix` | Output file name prefix | `LLM_Output` |
| `-h` | `--help` | Show help message | - |

### Examples

**Process current directory with default settings:**
```bash
./folderToLLM.sh
```

**Process a specific project with custom filters:**
```bash
./folderToLLM.sh -r "/path/to/project" -ie ".js,.py,.md" -ef ".git,dist,build"
```

**Include only Python and Markdown files:**
```bash
./folderToLLM.sh --include-extensions ".py,.md"
```

**Exclude large files and logs:**
```bash
./folderToLLM.sh --max-file-size 512000 --exclude-extensions ".zip,.log,.tmp"
```

**Process only specific folders:**
```bash
./folderToLLM.sh --include-folders "src,docs,tests"
```

## Script Architecture

The Mac version consists of five shell scripts, each with a specific responsibility:

| Script | Purpose |
|--------|---------|
| `folderToLLM.sh` | Entry point script (equivalent to `folderToLLM.bat`) |
| `collect_and_print.sh` | Main orchestration script (equivalent to `CollectAndPrint.ps1`) |
| `get_directory_structure.sh` | Generates formatted directory tree (equivalent to `Get-DirectoryStructure.ps1`) |
| `get_filtered_files.sh` | Filters files based on criteria (equivalent to `Get-FilteredFiles.ps1`) |
| `read_text_file_content.sh` | Safely reads file contents (equivalent to `Read-TextFileContent.ps1`) |
| `format_output_string.sh` | Assembles final output (equivalent to `Format-OutputString.ps1`) |

## Key Differences from Windows Version

### Advantages of Mac Version:
- **Native Support:** No need to install PowerShell
- **Better Performance:** Uses native Unix tools optimized for file operations
- **Enhanced Binary Detection:** Uses the `file` command for more accurate binary file detection
- **Cross-Platform:** Works on macOS and Linux
- **Colored Output:** Enhanced terminal output with colors for better readability

### Equivalent Functionality:
- All filtering options work identically
- Output format is exactly the same
- File size limits and binary detection work similarly
- Directory structure representation is identical

## Troubleshooting

### Common Issues

**"Permission denied" errors:**
```bash
chmod +x *.sh
```

**Scripts not found:**
Ensure all `.sh` files are in the same directory and the main script can find them.

**Binary files not detected properly:**
Make sure the `file` command is available (it should be pre-installed on macOS):
```bash
which file
```

**Tree characters not displaying correctly:**
Ensure your terminal supports UTF-8 encoding. Most modern terminals do by default.

### Debug Mode

To see detailed processing information, you can modify the scripts to enable debug output by uncommenting debug lines or adding:
```bash
set -x  # Add this line to any script for verbose output
```

## Compatibility

- **macOS:** All versions with bash (10.3+)
- **Linux:** Most distributions with bash 4.0+
- **Terminal:** Any terminal that supports UTF-8 for proper tree display

## Output

The script generates a timestamped text file (e.g., `LLM_Output_20241213143022.txt`) in the specified root directory containing:

1. **Header Information:** Timestamp and root directory
2. **Directory Structure:** Tree-like representation of all folders and files
3. **File Contents:** Content of all files that match the filtering criteria

## Contributing

If you find issues with the Mac version or want to add features:

1. Test your changes on both macOS and Linux if possible
2. Ensure compatibility with different versions of bash
3. Maintain the same command-line interface as the Windows version
4. Add appropriate error handling and user feedback

## License

Same license as the original Windows version. 