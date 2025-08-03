#!/bin/bash

# --- DEFINE YOUR VARIABLES AND DEFAULTS ---

# New: Set a default compression quality
DEFAULT_QUALITY=75

# --- INPUT VALIDATION ---

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory> [compression_quality]"
    echo "Example: $0 /path/to/my/images /path/to/my/compressed_images 80"
    echo "If [compression_quality] is not provided, it defaults to $DEFAULT_QUALITY."
    exit 1
fi

# Assign arguments to meaningful variable names
SOURCE_DIR="$1"
DEST_DIR="$2"

# New: Use the third argument if it exists, otherwise use the default.
# The :- operator is a standard shell parameter expansion trick.
# It means "if $3 is unset or null, use DEFAULT_QUALITY instead".
COMPRESSION_QUALITY="${3:-$DEFAULT_QUALITY}"

# --- SANITY CHECKS ---

# Check if the source directory exists and is a directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found or is not a directory."
    exit 1
fi

# Check if the destination directory argument is empty
if [ -z "$DEST_DIR" ]; then
    echo "Error: Destination directory argument cannot be empty."
    exit 1
fi

# --- THE SCRIPT ---

# 1. Setup
echo "Source Directory:      $SOURCE_DIR"
echo "Destination Directory: $DEST_DIR"
echo "Compression Quality:   $COMPRESSION_QUALITY"
echo "-------------------------------------"

mkdir -p "$DEST_DIR"
cd "$SOURCE_DIR" || { echo "ERROR: Could not cd to source directory. Aborting."; exit 1; }

# 2. Find all images and process them in a loop
echo "Starting compression process..."
# Using find with -print0 and read -d is more robust for special filenames
find . -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -print0 | while IFS= read -r -d $'\0' filename; do

  # Clean the filename by removing the leading "./"
  cleaned_filename="${filename#./}"

  # Construct the full path for the destination file
  output_path="$DEST_DIR/$cleaned_filename"
  output_dir=$(dirname "$output_path")

  # Create the destination directory for the file, if it doesn't exist.
  mkdir -p "$output_dir"

  # Now, run the conversion. It's guaranteed to work because the directory exists.
  echo "Processing: $cleaned_filename"

  # New: Use the $COMPRESSION_QUALITY variable in the command
  ~/bin/magick mogrify -path "$output_dir" -quality "$COMPRESSION_QUALITY" "$cleaned_filename"

done

echo "-------------------------------------"
echo "Compression complete!"
echo "Compressed files are in: $DEST_DIR"
