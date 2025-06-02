#!/bin/bash

# install_mac.sh - Installation script for FolderToLLM Mac version

echo "=========================================="
echo "FolderToLLM Mac Installation"
echo "=========================================="

# Make all shell scripts executable
echo "Making scripts executable..."
chmod +x *.sh

if [ $? -eq 0 ]; then
    echo "✓ All scripts are now executable"
else
    echo "✗ Failed to make scripts executable"
    exit 1
fi

# Test basic functionality
echo ""
echo "Testing basic functionality..."

if [ -f "folderToLLM.sh" ]; then
    echo "✓ Main script found"
    
    # Quick test
    if ./folderToLLM.sh --help >/dev/null 2>&1; then
        echo "✓ Scripts are working correctly"
    else
        echo "⚠ Warning: Script test failed, but files are ready"
    fi
else
    echo "✗ Main script not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "USAGE:"
echo "  ./folderToLLM.sh --help              # Show help"
echo "  ./folderToLLM.sh                     # Process current directory"
echo "  ./folderToLLM.sh -ie '.js,.py,.md'   # Include only specific file types"
echo "  ./folderToLLM.sh -ef '.git,dist'     # Exclude specific folders"
echo ""
echo "EXAMPLES:"
echo "  # Process a React project"
echo "  ./folderToLLM.sh -ie '.js,.jsx,.ts,.tsx,.json,.md' -ef 'node_modules,.git,dist,build'"
echo ""
echo "  # Process a Python project"
echo "  ./folderToLLM.sh -ie '.py,.md,.txt,.yml,.yaml' -ef '.venv,__pycache__,.git'"
echo ""
echo "  # Include only documentation"
echo "  ./folderToLLM.sh -ie '.md,.txt,.rst'"
echo ""
echo "OUTPUT:"
echo "  The script creates a timestamped .txt file (e.g., LLM_Output_20241213143022.txt)"
echo "  containing the directory structure and file contents for LLM context."
echo ""
echo "For global installation (optional):"
echo "  sudo cp *.sh /usr/local/bin/folderToLLM/"
echo "  sudo ln -sf /usr/local/bin/folderToLLM/folderToLLM.sh /usr/local/bin/folderToLLM"
echo ""
echo "==========================================" 