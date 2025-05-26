#!/bin/bash

# Usage:
# ./copy_files_with_regex.sh <sourcePath> <regexPattern> <destinationPath> [--noDestinationFolderNesting] [--datesFromRegex]

set -e

SOURCE_PATH="$1"
REGEX_PATTERN="$2"
DEST_PATH="$3"
NO_NESTING=false
DATES_FROM_REGEX=false

for arg in "$@"; do
  if [[ "$arg" == "--noDestinationFolderNesting" ]]; then
    NO_NESTING=true
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
    if $NO_NESTING; then
      relativePath="$filename"
    else
      relativePath="${file#$SOURCE_PATH/}"
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
