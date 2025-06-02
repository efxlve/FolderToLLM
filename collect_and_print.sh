#!/bin/bash

# collect_and_print.sh - Main script to collect directory structure and file contents
# Mac compatible version of CollectAndPrint.ps1

# Default values
ROOT_PATH="$(pwd)"
INCLUDE_FOLDER_PATHS=()
EXCLUDE_FOLDER_PATHS=("node_modules")
INCLUDE_EXTENSIONS=()
EXCLUDE_EXTENSIONS=(".env")
MIN_FILE_SIZE=-1
MAX_FILE_SIZE=1048576  # 1MB default
OUTPUT_FILE_NAME_PREFIX="LLM_Output"

# Default common development file extensions (when no specific extensions are given)
DEFAULT_DEV_EXTENSIONS=(".js" ".jsx" ".ts" ".tsx" ".py" ".dart" ".php" ".java" ".swift" ".go" ".rs" ".cpp" ".c" ".h" ".css" ".scss" ".sass" ".html" ".vue" ".svelte" ".md" ".txt" ".json" ".yaml" ".yml" ".xml" ".sql" ".sh" ".bat" ".ps1" ".rb" ".pl" ".r" ".scala" ".kt" ".cs" ".vb" ".f90" ".m" ".mm" ".plist" ".gradle" ".cmake" ".makefile" ".dockerfile")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Mac compatible version of FolderToLLM - Collect directory structure and file contents for LLM context.

By default, includes common development file types (.dart, .js, .py, .md, .json, etc.) when run without -ie option.

OPTIONS:
    -r, --root-path PATH            Root directory to process (default: current directory)
    -if, --include-folders FOLDERS  Comma-separated list of relative folder paths to include
    -ef, --exclude-folders FOLDERS  Comma-separated list of relative folder paths to exclude (default: node_modules)
    -ie, --include-extensions EXTS  Comma-separated list of file extensions to include (default: common dev files)
    -ee, --exclude-extensions EXTS  Comma-separated list of file extensions to exclude (default: .env)
    -min, --min-file-size SIZE      Minimum file size in bytes (-1 for no limit)
    -max, --max-file-size SIZE      Maximum file size in bytes (default: 1048576 = 1MB, -1 for no limit)
    -p, --prefix PREFIX             Prefix for the output file name (default: LLM_Output)
    -h, --help                      Show this help message

EXAMPLES:
    $0                              # Process current directory with default file types
    $0 -ef ".git,build"            # Exclude specific folders, use default file types
    $0 -ie ".dart,.yaml"           # Include only specific file types
    $0 -r "/path/to/project"       # Process specific directory with defaults

EOF
}

# Function to parse comma-separated values into array
parse_csv() {
    local input="$1"
    if [ -n "$input" ]; then
        echo "$input" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--root-path)
            ROOT_PATH="$2"
            shift 2
            ;;
        -if|--include-folders)
            IFS=$'\n' read -d '' -ra INCLUDE_FOLDER_PATHS < <(parse_csv "$2" && printf '\0')
            shift 2
            ;;
        -ef|--exclude-folders)
            IFS=$'\n' read -d '' -ra EXCLUDE_FOLDER_PATHS < <(parse_csv "$2" && printf '\0')
            shift 2
            ;;
        -ie|--include-extensions)
            IFS=$'\n' read -d '' -ra INCLUDE_EXTENSIONS < <(parse_csv "$2" && printf '\0')
            shift 2
            ;;
        -ee|--exclude-extensions)
            IFS=$'\n' read -d '' -ra EXCLUDE_EXTENSIONS < <(parse_csv "$2" && printf '\0')
            shift 2
            ;;
        -min|--min-file-size)
            MIN_FILE_SIZE="$2"
            shift 2
            ;;
        -max|--max-file-size)
            MAX_FILE_SIZE="$2"
            shift 2
            ;;
        -p|--prefix)
            OUTPUT_FILE_NAME_PREFIX="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper scripts
source "$SCRIPT_DIR/get_directory_structure.sh" || {
    echo -e "${RED}Error: Failed to load get_directory_structure.sh${NC}"
    exit 1
}

source "$SCRIPT_DIR/get_filtered_files.sh" || {
    echo -e "${RED}Error: Failed to load get_filtered_files.sh${NC}"
    exit 1
}

source "$SCRIPT_DIR/read_text_file_content.sh" || {
    echo -e "${RED}Error: Failed to load read_text_file_content.sh${NC}"
    exit 1
}

source "$SCRIPT_DIR/format_output_string.sh" || {
    echo -e "${RED}Error: Failed to load format_output_string.sh${NC}"
    exit 1
}

# Normalize ROOT_PATH to absolute path
ROOT_PATH="$(cd "$ROOT_PATH" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Cannot access directory: $ROOT_PATH${NC}"
    exit 1
}

# Normalize extensions (ensure they start with a dot and are lowercase)
normalize_extensions() {
    local arr_name="$1"
    local normalized=()
    eval "local arr=(\"\${${arr_name}[@]}\")"
    for ext in "${arr[@]}"; do
        ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]' | sed 's/^[^.]/.\0/')
        normalized+=("$ext")
    done
    eval "${arr_name}=(\"\${normalized[@]}\")"
}

# Normalize extension arrays
normalize_extensions INCLUDE_EXTENSIONS
normalize_extensions EXCLUDE_EXTENSIONS

# If no include extensions specified, use default development extensions
if [ ${#INCLUDE_EXTENSIONS[@]} -eq 0 ]; then
    INCLUDE_EXTENSIONS=("${DEFAULT_DEV_EXTENSIONS[@]}")
    echo -e "${MAGENTA}No extensions specified, using default development file types${NC}"
fi

# Display effective parameters
echo -e "${BLUE}Processing directory: $ROOT_PATH${NC}"
echo -e "${CYAN}Include folders: ${INCLUDE_FOLDER_PATHS[*]}${NC}"
echo -e "${CYAN}Exclude folders: ${EXCLUDE_FOLDER_PATHS[*]}${NC}"
echo -e "${CYAN}Include extensions: ${INCLUDE_EXTENSIONS[*]}${NC}"
echo -e "${CYAN}Exclude extensions: ${EXCLUDE_EXTENSIONS[*]}${NC}"
echo -e "${CYAN}Max file size: $MAX_FILE_SIZE bytes${NC}"

# 1. Generate directory structure
echo -e "${YELLOW}Generating directory structure...${NC}"
DIRECTORY_STRUCTURE=$(get_directory_structure_formatted "$ROOT_PATH")

# 2. Get filtered files
echo -e "${YELLOW}Filtering files...${NC}"
FILTERED_FILES=()
while IFS= read -r -d '' file; do
    FILTERED_FILES+=("$file")
done < <(get_filtered_file_items "$ROOT_PATH" INCLUDE_FOLDER_PATHS EXCLUDE_FOLDER_PATHS INCLUDE_EXTENSIONS EXCLUDE_EXTENSIONS "$MIN_FILE_SIZE" "$MAX_FILE_SIZE" | tr '\n' '\0')

echo -e "${GREEN}Found ${#FILTERED_FILES[@]} files matching criteria.${NC}"

# 3. Format the output
echo -e "${YELLOW}Formatting output...${NC}"
FINAL_OUTPUT=$(format_output_string "$ROOT_PATH" "$DIRECTORY_STRUCTURE" FILTERED_FILES)

# 4. Output to file
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
OUTPUT_FILE_PATH="$ROOT_PATH/${OUTPUT_FILE_NAME_PREFIX}_${TIMESTAMP}.txt"

echo -e "${YELLOW}Writing output to: $OUTPUT_FILE_PATH${NC}"
echo "$FINAL_OUTPUT" > "$OUTPUT_FILE_PATH" || {
    echo -e "${RED}Error: Failed to write output file${NC}"
    exit 1
}

echo -e "${GREEN}Successfully generated output file.${NC}"

# Optional: Display a snippet or confirmation
if [ -f "$OUTPUT_FILE_PATH" ] && [ "$(wc -c < "$OUTPUT_FILE_PATH")" -lt 20000 ]; then
    echo -e "\n${CYAN}--- Output File Preview (first 20 lines) ---${NC}"
    head -20 "$OUTPUT_FILE_PATH"
elif [ -f "$OUTPUT_FILE_PATH" ]; then
    echo -e "\n${YELLOW}Output file is large. Preview skipped.${NC}"
fi

echo -e "${GREEN}Script finished.${NC}" 