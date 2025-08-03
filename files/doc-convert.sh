#!/bin/bash

# --- A script to convert DOC/DOCX files, with an option for recursion ---

# --- INPUT VALIDATION ---

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <source_directory> <destination_directory> <format> [--recursive]"
    echo ""
    echo "  <format>:      Must be either 'pdf' or 'odt'."
    echo "  --recursive:   Optional. If provided, finds and converts files in ALL subdirectories,"
    echo "                 preserving the original folder structure in the destination."
    echo "                 If omitted, only files in the top-level source directory are converted."
    echo ""
    echo "Example (Recursive): $0 ./docs ./pdfs pdf --recursive"
    echo "Example (Top-Level): $0 ./docs ./odts odt"
    exit 1
fi

SOURCE_DIR=$(realpath "$1") # Get the full, absolute path
DEST_DIR=$(realpath "$2")   # Get the full, absolute path
OUTPUT_FORMAT=$(echo "$3" | tr '[:upper:]' '[:lower:]')

RECURSIVE_MODE=false
if [ "$4" == "--recursive" ]; then
    RECURSIVE_MODE=true
fi

# --- SANITY CHECKS ---

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$1' not found."
    exit 1
fi
if [[ "$OUTPUT_FORMAT" != "pdf" && "$OUTPUT_FORMAT" != "odt" ]]; then
    echo "Error: Invalid format '$3'. Please choose 'pdf' or 'odt'."
    exit 1
fi

# --- THE SCRIPT ---

# 1. Setup
echo "Source Directory:      $SOURCE_DIR"
echo "Destination Directory: $DEST_DIR"
echo "Target Format:         $OUTPUT_FORMAT"
if [ "$RECURSIVE_MODE" == true ]; then
    echo "Mode:                  Recursive"
else
    echo "Mode:                  Top-Level Only"
fi
echo "-------------------------------------"
mkdir -p "$DEST_DIR"

# 2. Determine the conversion filter
CONVERT_FILTER="$OUTPUT_FORMAT"
if [ "$OUTPUT_FORMAT" == "pdf" ]; then
    CONVERT_FILTER="pdf:writer_pdf_Export"
fi

# 3. --- CHOOSE CONVERSION METHOD BASED ON MODE ---

if [ "$RECURSIVE_MODE" == true ]; then
    # --- CORRECTED RECURSIVE LOGIC (using find) ---
    echo "Starting RECURSIVE conversion, preserving structure..."
    
    find "$SOURCE_DIR" -type f \( -iname "*.doc" -o -iname "*.docx" \) -print0 | while IFS= read -r -d $'\0' source_file; do
        
        # This is the magic part. It calculates the relative path of the file
        # from the source directory, e.g., "level1/level2/document.doc"
        relative_path="${source_file#$SOURCE_DIR/}"
        
        # Now, determine the final destination DIRECTORY for this specific file
        dest_sub_dir="$DEST_DIR/$(dirname "$relative_path")"
        
        # Create that specific subdirectory in the destination
        mkdir -p "$dest_sub_dir"
        
        echo "  -> Converting: $relative_path"
        
        # Tell soffice to output this ONE file into its correct destination subdirectory
        soffice --headless --convert-to "$CONVERT_FILTER" --outdir "$dest_sub_dir" "$source_file"
    done

else
    # --- NON-RECURSIVE LOGIC (top-level only) ---
    echo "Starting NON-RECURSIVE conversion..."
    # This works as expected because it only processes one level
    soffice --headless --convert-to "$CONVERT_FILTER" --outdir "$DEST_DIR" "$SOURCE_DIR"/*.{doc,docx}
fi


# --- FINAL MESSAGE ---
if [ $? -eq 0 ]; then
    echo "-------------------------------------"
    echo "Conversion completed successfully!"
    echo "Output files are in: $DEST_DIR"
else
    echo "-------------------------------------"
    echo "Warning: The soffice command may have finished with an error."
    echo "Some files may not have been converted."
fi
