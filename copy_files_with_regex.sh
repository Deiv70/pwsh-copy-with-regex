#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATH=""
DESTINATION_PATH=""
ONLY_PRINT=false
CHANGE_FILENAME=true
NO_NESTING=true
DATES_FROM_REGEX=true
REGEX_PATTERN='(?:(?:IMG|VID)[_-]+)?(?<year>\d{4})[_-]?(?<month>\d{2})[_-]?(?<day>\d{2})[_-]+(?:(?<hours>\d{2})[_-]?(?<minutes>\d{2})[_-]?(?<seconds>\d{2})|WA(?<hours_wa>\d{2})(?<minutes_wa>\d{2})(?:[~_-].*)?)\.(?:jpe?g|png|mp4)$'
# Good Example:
# '(?:IMG|VID)[_-](?<year>\d{4})(?<month>\d{2})(?<day>\d{2})[_-](?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2}).(?:JPE?G|PNG|MP4|jpe?g|png|mp4)$'
# Example including WhatsApp old format:
# '(?:IMG|VID)[_-](?<year>\d{4})(?<month>\d{2})(?<day>\d{2})[_-](?:(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})|WA(?<hours_wa>\d{2})(?<minutes_wa>\d{2})).(?:JPE?G|PNG|MP4|jpe?g|png|mp4)$'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only-print-paths) ONLY_PRINT=true; shift ;;
    --regex-pattern) REGEX_PATTERN="$2"; shift 2 ;;
    --dates-from-regex) DATES_FROM_REGEX=true; shift ;;
    --change-file-name) CHANGE_FILENAME=true; shift ;;
    --no-destination-folder-nesting) NO_NESTING=true; shift ;;
    --source-path) SOURCE_PATH="$2"; shift 2 ;;
    --destination-path) DESTINATION_PATH="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$SOURCE_PATH" && -n "$DESTINATION_PATH" && -n "$REGEX_PATTERN" ]] || {
  echo "Missing required args" >&2
  exit 1
}
#echo "perl ./copy_files_with_regex.pl '${SOURCE_PATH}' '${DESTINATION_PATH}' '${REGEX_PATTERN}' '${ONLY_PRINT}' '${CHANGE_FILENAME}' '${NO_NESTING}' '${DATES_FROM_REGEX}'"
perl ./copy_files_with_regex.pl "${SOURCE_PATH}" "${DESTINATION_PATH}" "${REGEX_PATTERN}" "${ONLY_PRINT}" "${CHANGE_FILENAME}" "${NO_NESTING}" "${DATES_FROM_REGEX}"
