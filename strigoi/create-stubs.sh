#!/bin/bash
# Generate stub markdown files from SUMMARY.md

cd src

# Extract all markdown file paths from SUMMARY.md
grep -oE '\./[^)]+\.md' SUMMARY.md | sort -u | while read -r file; do
    # Remove leading ./
    file="${file#./}"
    
    # Skip if file already exists
    if [ -f "$file" ]; then
        echo "✓ Exists: $file"
        continue
    fi
    
    # Create directory if needed
    dir="$(dirname "$file")"
    mkdir -p "$dir"
    
    # Extract page title from SUMMARY.md
    title=$(grep "$file" ../src/SUMMARY.md | sed 's/.*\[\(.*\)\].*/\1/' | head -1)
    
    # Create stub file
    cat > "$file" << STUB
# $title

**This page is under construction.** 🚧

Content coming soon!

---

## Quick Links

- [Back to Getting Started](../getting-started/README.md)
- [View Documentation Home](../introduction.md)
- [Installation Guide](../getting-started/installation/README.md)

---

*This is a placeholder page. Full documentation will be added iteratively.*
STUB
    
    echo "✨ Created: $file"
done

echo ""
echo "✅ Stub generation complete!"
