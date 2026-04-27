#!/bin/bash

# Usage:
# ./copy_files_with_regex.sh <regexPattern> <sourcePath> <destinationPath> [--noDestinationFolderNesting] [--datesFromRegex]

set -euo pipefail

REGEX_PATTERN="$1"
SOURCE_PATH="$2"
DEST_PATH="$3"
FOLDER_NESTING=true
DATES_FROM_REGEX=false

for arg in "$@"; do
  if [[ "$arg" == "--noDestinationFolderNesting" ]]; then
    FOLDER_NESTING=false
  elif [[ "$arg" == "--datesFromRegex" ]]; then
    DATES_FROM_REGEX=true
  fi
done

# Create destination path
mkdir -p "$DEST_PATH"

# Iterate through matching files
find "$SOURCE_PATH" -type f | while read -r file; do
  filename=$(basename "$file")

  if [[ "$filename" =~ $REGEX_PATTERN ]]; then
    # Extract date components if requested
    if $DATES_FROM_REGEX; then
      year="${BASH_REMATCH[1]}"
      month="${BASH_REMATCH[2]}"
      day="${BASH_REMATCH[3]}"
      hours="${BASH_REMATCH[4]}"
      minutes="${BASH_REMATCH[5]}"
      seconds="${BASH_REMATCH[6]}"
    fi

    # Build destination path
    if $FOLDER_NESTING; then
      relativePath="${file#$SOURCE_PATH/}"
    else
      relativePath="$filename"
    fi

    destFile="$DEST_PATH/$relativePath"
    destDir=$(dirname "$destFile")
    mkdir -p "$destDir"

    cp -p "$file" "$destFile"

    # Set timestamps
    if $DATES_FROM_REGEX; then
      timestamp="$year-$month-$day $hours:$minutes:$seconds"
      touch -d "$timestamp" "$destFile"
    else
      # Preserve original timestamps
      touch -r "$file" "$destFile"
    fi
  fi
done
