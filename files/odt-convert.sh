#!/bin/bash

# --- A script to convert ODT files to PDF, with an option for recursion ---

# --- INPUT VALIDATION ---

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <source_odt_directory> <destination_pdf_directory> [--recursive]"
    echo ""
    echo "  --recursive:   Optional. If provided, finds and converts files in ALL subdirectories,"
    echo "                 preserving the original folder structure in the destination."
    echo "                 If omitted, only files in the top-level source directory are converted."
    echo ""
    echo "Example (Recursive): $0 ./my_odts ./my_pdfs --recursive"
    echo "Example (Top-Level): $0 ./my_odts ./my_pdfs"
    exit 1
fi

# Use realpath to get the full, absolute path, preventing relative path issues
SOURCE_DIR=$(realpath "$1") 
DEST_DIR=$(realpath "$2")

# --- Check for the optional recursive flag ---
RECURSIVE_MODE=false
# Check if the third argument is --recursive
if [ "$3" == "--recursive" ]; then
    RECURSIVE_MODE=true
fi

# --- SANITY CHECKS ---

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$1' not found."
    exit 1
fi

# --- THE SCRIPT ---

# 1. Setup
echo "Source Directory:      $SOURCE_DIR"
echo "Destination Directory: $DEST_DIR"
if [ "$RECURSIVE_MODE" == true ]; then
    echo "Mode:                  Recursive"
else
    echo "Mode:                  Top-Level Only"
fi
echo "-------------------------------------"
mkdir -p "$DEST_DIR"

echo "Note: PDF conversion will use the image compression settings"
echo "last saved in the LibreOffice GUI (File -> Export As -> PDF)."
echo ""

# 2. --- CHOOSE CONVERSION METHOD BASED ON MODE ---

if [ "$RECURSIVE_MODE" == true ]; then
    # --- CORRECTED RECURSIVE LOGIC (using find) ---
    echo "Starting RECURSIVE conversion, preserving structure..."
    
    find "$SOURCE_DIR" -type f -iname "*.odt" -print0 | while IFS= read -r -d $'\0' source_file; do
        
        # Calculate the relative path of the file from the source directory
        relative_path="${source_file#$SOURCE_DIR/}"
        
        # Determine the final destination DIRECTORY for this specific file
        dest_sub_dir="$DEST_DIR/$(dirname "$relative_path")"
        
        # Create that specific subdirectory in the destination
        mkdir -p "$dest_sub_dir"
        
        echo "  -> Converting: $relative_path"
        
        # Tell soffice to output this ONE file into its correct destination subdirectory
        soffice --headless --convert-to "pdf:writer_pdf_Export" --outdir "$dest_sub_dir" "$source_file"
    done

else
    # --- NON-RECURSIVE LOGIC (top-level only) ---
    echo "Starting NON-RECURSIVE conversion..."
    # This works as expected because it only processes one level
    soffice --headless --convert-to "pdf:writer_pdf_Export" --outdir "$DEST_DIR" "$SOURCE_DIR"/*.odt
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
