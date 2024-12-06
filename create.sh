#!/bin/bash

# Check if a path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

# Extract the provided path
path=$1

# Get the current date in the format YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# Determine if the path is a file or a directory
if [[ $path == *.md ]]; then
    # Treat as a file
    base_dir=$(dirname "$path")
    file_name=$(basename "$path")
    # Add date prefix to the file name
    file_name="$current_date-$file_name"
else
    # Treat as a directory
    base_dir="$path"
    # Prompt for the file name
    read -p "Enter the file name: " input_name
    # Ensure the file name ends with .md
    if [[ $input_name != *.md ]]; then
        input_name="$input_name.md"
    fi
    # Add date prefix to the file name
    file_name="$current_date-$input_name"
fi

# Ensure the base directory exists
mkdir -p "$base_dir"

# Handle _index.md creation in the base directory
index_file="$base_dir/_index.md"
if [ ! -f "$index_file" ]; then
    cat > "$index_file" << EOF
+++
sort_by = "date"
generate_feeds = true
+++
EOF
    echo "Created _index.md in $base_dir"
fi

# Create the target markdown file
target_file="$base_dir/$file_name"
cat > "$target_file" << EOF
+++
[taxonomies]
tags = []
authors = ["Jiangqiu Shen"]
+++
EOF

echo "File created: $target_file"
