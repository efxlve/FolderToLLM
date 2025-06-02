#!/bin/bash

# folderToLLM.sh - Mac compatible version of FolderToLLM
# Main script to collect directory structure and file contents for LLM context

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the main collection script
MAIN_SCRIPT_PATH="$SCRIPT_DIR/collect_and_print.sh"

# Check if the main script exists
if [ ! -f "$MAIN_SCRIPT_PATH" ]; then
    echo "Error: Main script not found at $MAIN_SCRIPT_PATH"
    echo "Please ensure collect_and_print.sh is in the same directory as this script."
    exit 1
fi

# Make sure the main script is executable
chmod +x "$MAIN_SCRIPT_PATH"

# Run the main script and pass all arguments
exec "$MAIN_SCRIPT_PATH" "$@" 