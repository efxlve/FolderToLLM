#!/bin/bash

# debug_dart_issue.sh - Debug script to test .dart file handling

echo "🔍 Dart Dosyaları Debug Testi"
echo "==============================="

# Source the required functions
source "get_filtered_files.sh"
source "read_text_file_content.sh"

# Test with a sample dart file if available
echo "1. Dart dosyalarını arıyoruz..."
find . -name "*.dart" -type f | head -5 | while read dart_file; do
    if [ -f "$dart_file" ]; then
        echo "  Bulundu: $dart_file"
        
        # Test extension detection
        ext=$(get_file_extension "$dart_file")
        echo "    Algılanan uzantı: '$ext'"
        
        # Test binary detection
        if is_binary_file "$dart_file"; then
            echo "    ❌ Binary olarak algılandı"
        else
            echo "    ✅ Text dosyası olarak algılandı"
        fi
        
        # Test file type detection
        if command -v file >/dev/null 2>&1; then
            file_type=$(file -b --mime-type "$dart_file" 2>/dev/null)
            echo "    MIME type: $file_type"
        fi
        
        # Test file size
        size=$(get_file_size "$dart_file")
        echo "    Dosya boyutu: $size bytes"
        
        echo ""
    fi
done

echo "2. Dart uzantısını test edelim:"
echo "   .dart uzantısı normalize ediliyor..."

# Test extension normalization
test_ext=".dart"
normalized_ext=$(echo "$test_ext" | tr '[:upper:]' '[:lower:]' | sed 's/^[^.]/.\0/')
echo "   Sonuç: '$normalized_ext'"

echo ""
echo "3. Önerilen test komutu:"
echo "   ./folderToLLM.sh -r \"/path/to/your/flutter-project\" -ie \".dart,.yaml,.md\" -ef \".git,build,.dart_tool\""

echo ""
echo "4. Manuel test için:"
echo "   Bir dart dosyasının içeriğini okuyalım..."

# Find first dart file and try to read it
first_dart=$(find . -name "*.dart" -type f | head -1)
if [ -n "$first_dart" ]; then
    echo "   Test dosyası: $first_dart"
    echo "   İçerik önizleme:"
    echo "   =================================="
    head -10 "$first_dart" 2>/dev/null || echo "   ❌ Dosya okunamadı"
    echo "   =================================="
else
    echo "   ⚠️  Bu dizinde .dart dosyası bulunamadı"
fi 