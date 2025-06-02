#!/bin/bash

# format_output_string.sh - Format the final output string
# Mac compatible version of Format-OutputString.ps1

# Function to format the complete output
format_output_string() {
    local root_directory="$1"
    local directory_structure="$2"
    local files_array_name="$3[@]"
    local files_array=("${!files_array_name}")
    
    # Build the output
    echo "LLM File Collector Output"
    echo "Root Directory: $root_directory"
    echo "Execution Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=================================================="
    echo ""
    echo "DIRECTORY STRUCTURE:"
    echo "--------------------------------------------------"
    echo "$directory_structure"
    echo ""
    echo "=================================================="
    echo "FILE CONTENTS:"
    echo "--------------------------------------------------"
    echo ""
    
    # Process each file
    if [ ${#files_array[@]} -gt 0 ]; then
        for file_path in "${files_array[@]}"; do
            local file_size=$(get_file_size "$file_path")
            echo "--- START: $file_path ($file_size bytes) ---"
            read_safe_text_file_content "$file_path"
            echo "--- END: $file_path ---"
            echo ""
        done
    else
        echo "No files matched the criteria or were found."
    fi
} 