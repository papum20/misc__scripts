#!/bin/bash

# --- Script using ocrmypdf for optimization ---

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found."
    exit 1
fi

# 2. --- Main Logic ---
echo "Source: $SOURCE_DIR"
echo "Destination: $DEST_DIR"
mkdir -p "$DEST_DIR"

cd "$SOURCE_DIR" || { echo "FATAL: Could not cd to '$SOURCE_DIR'. Aborting."; exit 1; }
echo "Processing PDFs in: $(pwd)"

# 3. --- The Processing Loop ---
echo "Starting PDF optimization with ocrmypdf..."
find . -type f -iname "*.pdf" | while IFS= read -r filename; do

  cleaned_filename="${filename#./}"
  output_path="$DEST_DIR/$cleaned_filename"

  mkdir -p "$(dirname "$output_path")"

  echo "  -> Optimizing $cleaned_filename"
  
  # The ocrmypdf command
  # --skip-text tells it not to perform OCR if a text layer already exists.
  # --optimize 3 provides aggressive, lossy compression.
  ocrmypdf --skip-text --optimize 3 "$cleaned_filename" "$output_path"

done

echo "-------------------------------------"
echo "PDF optimization complete!"
