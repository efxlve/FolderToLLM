#!/bin/bash

# get_filtered_files.sh - Filter files based on various criteria
# Mac compatible version of Get-FilteredFiles.ps1

# Function to check if a file path matches any folder in the list
path_matches_folder() {
    local file_path="$1"
    local folder_list_name="$2[@]"
    local folder_list=("${!folder_list_name}")
    
    for folder in "${folder_list[@]}"; do
        # Convert relative folder path to absolute
        local abs_folder="$(cd "$ROOT_PATH" 2>/dev/null && cd "$folder" 2>/dev/null && pwd)"
        if [ -n "$abs_folder" ] && [[ "$file_path" == "$abs_folder"/* || "$file_path" == "$abs_folder" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if extension is in the list
extension_in_list() {
    local file_ext="$1"
    local ext_list_name="$2[@]"
    local ext_list=("${!ext_list_name}")
    
    # Convert to lowercase for comparison
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]')
    
    for ext in "${ext_list[@]}"; do
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        if [ "$file_ext" = "$ext" ]; then
            return 0
        fi
    done
    return 1
}

# Function to get file size in bytes
get_file_size() {
    local file="$1"
    if [ -f "$file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            stat -f%z "$file" 2>/dev/null || echo 0
        else
            # Linux
            stat -c%s "$file" 2>/dev/null || echo 0
        fi
    else
        echo 0
    fi
}

# Function to get file extension
get_file_extension() {
    local file="$1"
    local basename_file=$(basename "$file")
    if [[ "$basename_file" == *.* ]]; then
        echo ".${basename_file##*.}" | tr '[:upper:]' '[:lower:]'
    else
        echo ""
    fi
}

# Function to check if file is likely binary
is_binary_file() {
    local file="$1"
    local ext=$(get_file_extension "$file")
    
    # Common binary extensions
    local binary_exts=(.exe .dll .zip .gz .tar .jpg .jpeg .png .gif .bmp .iso .mp3 .mp4 .pdf .doc .xls .ppt .docx .xlsx .pptx .bin .obj .so .dylib .a .dmg .pkg)
    
    for binary_ext in "${binary_exts[@]}"; do
        if [ "$ext" = "$binary_ext" ]; then
            return 0
        fi
    done
    
    # Use file command to detect binary files
    if command -v file >/dev/null 2>&1; then
        local file_type=$(file -b --mime-type "$file" 2>/dev/null)
        if [[ "$file_type" == application/* ]] && [[ "$file_type" != "application/json" ]] && [[ "$file_type" != "application/xml" ]]; then
            return 0
        fi
        if [[ "$file_type" == image/* ]] || [[ "$file_type" == audio/* ]] || [[ "$file_type" == video/* ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Main function to get filtered file items
get_filtered_file_items() {
    local root_path="$1"
    local include_folders_name="$2"
    local exclude_folders_name="$3"
    local include_extensions_name="$4"
    local exclude_extensions_name="$5"
    local min_size="$6"
    local max_size="$7"
    
    # Get absolute path
    root_path="$(cd "$root_path" 2>/dev/null && pwd)" || {
        echo "Error: Cannot access directory: $root_path" >&2
        return 1
    }
    
    # Find all files recursively
    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$root_path" -type f -print0 2>/dev/null)
    
    # Filter files
    for file in "${files[@]}"; do
        local should_include=true
        local file_dir=$(dirname "$file")
        local file_ext=$(get_file_extension "$file")
        local file_size=$(get_file_size "$file")
        
        # Check include folders filter
        local include_folders_ref="$include_folders_name[@]"
        local include_folders=("${!include_folders_ref}")
        if [ ${#include_folders[@]} -gt 0 ]; then
            if ! path_matches_folder "$file" "$include_folders_name"; then
                should_include=false
            fi
        fi
        
        # Check exclude folders filter
        if [ "$should_include" = true ]; then
            if path_matches_folder "$file" "$exclude_folders_name"; then
                should_include=false
            fi
        fi
        
        # Check include extensions filter
        if [ "$should_include" = true ]; then
            local include_extensions_ref="$include_extensions_name[@]"
            local include_extensions=("${!include_extensions_ref}")
            if [ ${#include_extensions[@]} -gt 0 ]; then
                if ! extension_in_list "$file_ext" "$include_extensions_name"; then
                    should_include=false
                fi
            fi
        fi
        
        # Check exclude extensions filter
        if [ "$should_include" = true ]; then
            if extension_in_list "$file_ext" "$exclude_extensions_name"; then
                should_include=false
            fi
        fi
        
        # Check minimum file size
        if [ "$should_include" = true ] && [ "$min_size" -ge 0 ]; then
            if [ "$file_size" -lt "$min_size" ]; then
                should_include=false
            fi
        fi
        
        # Check maximum file size
        if [ "$should_include" = true ] && [ "$max_size" -ge 0 ]; then
            if [ "$file_size" -gt "$max_size" ]; then
                should_include=false
            fi
        fi
        
        # Skip binary files (unless specifically included by extension)
        if [ "$should_include" = true ]; then
            if is_binary_file "$file"; then
                should_include=false
            fi
        fi
        
        # Output file if it should be included
        if [ "$should_include" = true ]; then
            echo "$file"
        fi
    done
} 