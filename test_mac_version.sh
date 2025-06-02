#!/bin/bash

# test_mac_version.sh - Test script for Mac version

echo "Testing FolderToLLM Mac Version..."

# Check if all scripts exist
scripts=("folderToLLM.sh" "collect_and_print.sh" "get_directory_structure.sh" "get_filtered_files.sh" "read_text_file_content.sh" "format_output_string.sh")

echo "Checking if all scripts exist..."
for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        echo "✓ $script exists"
    else
        echo "✗ $script missing"
        exit 1
    fi
done

# Check if scripts are executable
echo "Checking if scripts are executable..."
for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo "✓ $script is executable"
    else
        echo "✗ $script is not executable"
        echo "Run: chmod +x *.sh"
        exit 1
    fi
done

# Test help function
echo "Testing help function..."
./folderToLLM.sh --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Help function works"
else
    echo "✗ Help function failed"
    exit 1
fi

# Test with specific filters
echo "Testing with specific filters..."
./folderToLLM.sh -ie ".md,.sh" -max 50000 -p "MacTest_Output" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Script execution completed successfully"
    
    # Check if output file was created
    if ls MacTest_Output_*.txt 1> /dev/null 2>&1; then
        echo "✓ Output file was created"
        latest_file=$(ls -t MacTest_Output_*.txt | head -1)
        echo "  Created: $latest_file"
        
        # Check file content structure
        if grep -q "LLM File Collector Output" "$latest_file"; then
            echo "✓ Output file has correct header"
        else
            echo "✗ Output file missing header"
        fi
        
        if grep -q "DIRECTORY STRUCTURE:" "$latest_file"; then
            echo "✓ Output file has directory structure section"
        else
            echo "✗ Output file missing directory structure"
        fi
        
        if grep -q "FILE CONTENTS:" "$latest_file"; then
            echo "✓ Output file has file contents section"
        else
            echo "✗ Output file missing file contents section"
        fi
        
    else
        echo "✗ Output file was not created"
        exit 1
    fi
else
    echo "✗ Script execution failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed! The Mac version is working correctly."
echo ""
echo "You can now use the following commands:"
echo "  ./folderToLLM.sh --help                    # Show help"
echo "  ./folderToLLM.sh                           # Process current directory"
echo "  ./folderToLLM.sh -ie '.js,.py' -ef '.git' # Custom filters" 