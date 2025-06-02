#!/bin/bash

# read_text_file_content.sh - Safely read text file content
# Mac compatible version of Read-TextFileContent.ps1

# Function to read safe text file content
read_safe_text_file_content() {
    local file_path="$1"
    local max_chars_to_read="${2:-1000000}"  # Default 1MB worth of characters
    
    # Check if file exists
    if [ ! -f "$file_path" ]; then
        echo "[Error: File not found: $(basename "$file_path")]"
        return 1
    fi
    
    # Get file size
    local file_size=$(get_file_size "$file_path")
    local file_name=$(basename "$file_path")
    
    # Check if file is empty
    if [ "$file_size" -eq 0 ]; then
        echo "[Empty File: $file_name]"
        return 0
    fi
    
    # Check if file is binary using the same function from get_filtered_files.sh
    if is_binary_file "$file_path"; then
        echo "[Binary File: $file_name - Content not displayed]"
        return 0
    fi
    
    # Additional binary check using file command
    if command -v file >/dev/null 2>&1; then
        local file_type=$(file -b "$file_path" 2>/dev/null)
        if [[ "$file_type" == *"binary"* ]] || [[ "$file_type" == *"executable"* ]]; then
            echo "[Binary File: $file_name - Content not displayed]"
            return 0
        fi
    fi
    
    # Check for very large files
    local max_file_size=$((max_chars_to_read * 2))  # Rough approximation
    if [ "$file_size" -gt "$max_file_size" ]; then
        echo "[Large File: $file_name ($file_size bytes) - Reading first $max_chars_to_read characters]"
        # Read first portion of the file
        if command -v head >/dev/null 2>&1; then
            local lines_to_read=$((max_chars_to_read / 80))  # Rough estimate of lines
            head -n "$lines_to_read" "$file_path" 2>/dev/null || {
                echo "[Error Reading File: $file_name - Could not read content]"
                return 1
            }
            echo "... [TRUNCATED - File continues beyond $max_chars_to_read characters]"
        else
            echo "[Error: head command not available for reading large file: $file_name]"
            return 1
        fi
    else
        # Read entire file content
        if ! cat "$file_path" 2>/dev/null; then
            # If cat fails, try to read with error handling
            echo "[Error Reading File: $file_name - Content may contain invalid characters]"
            return 1
        fi
    fi
    
    return 0
} 