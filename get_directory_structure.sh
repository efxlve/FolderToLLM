#!/bin/bash

# get_directory_structure.sh - Generate formatted directory tree structure
# Mac compatible version of Get-DirectoryStructure.ps1

# Function to recursively generate directory structure
get_directory_structure_formatted() {
    local path="$1"
    local indent="$2"
    
    # Default indent to empty string if not provided
    if [ -z "$indent" ]; then
        indent=""
    fi
    
    # Check if path exists and is a directory
    if [ ! -d "$path" ]; then
        echo "Error: $path is not a valid directory" >&2
        return 1
    fi
    
    # Get all items in the directory, sort them (directories first, then files)
    local dirs=()
    local files=()
    
    # Read directories and files into separate arrays
    while IFS= read -r -d '' item; do
        if [ -d "$item" ]; then
            dirs+=("$(basename "$item")")
        else
            files+=("$(basename "$item")")
        fi
    done < <(find "$path" -maxdepth 1 -not -path "$path" -print0 2>/dev/null | sort -z)
    
    # Combine sorted arrays - directories first, then files
    local all_items=("${dirs[@]}" "${files[@]}")
    local total_count=${#all_items[@]}
    local processed_count=0
    
    # Process each item
    for item in "${all_items[@]}"; do
        processed_count=$((processed_count + 1))
        local is_last=$((processed_count == total_count))
        local item_path="$path/$item"
        
        # Determine the prefix for current item
        if [ $is_last -eq 1 ]; then
            local line_prefix="└── "
            local child_indent="    "
        else
            local line_prefix="├── "
            local child_indent="│   "
        fi
        
        # Print current item
        echo "${indent}${line_prefix}${item}"
        
        # If it's a directory, recurse into it
        if [ -d "$item_path" ]; then
            get_directory_structure_formatted "$item_path" "${indent}${child_indent}"
        fi
    done
} 