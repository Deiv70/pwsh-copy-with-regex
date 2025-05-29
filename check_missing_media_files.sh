#!/bin/bash

ORIGIN_PATH="$1"
DEST_PATH="$2"
#REGEXP_IGNORED_PATTERN=".*\/\..*\/.*$"
REGEXP_IGNORED_PATTERN=".*\.tmp$"
REGEXP_PATTERN="\.(arw|cr2|cr3|nef|nrw|orf|raf|raw|rw2|dng|srw|pef|mos|kdc|3fr|x3f|mp4|mov|mkv|avi|wmv|flv|webm|m4v|mpg|mpeg|wav|aiff|aif|bwf|jpe?g|png|mp4)$"
INDEX_FILENAME="index_mediaFiles.txt"
MISSING_FILENAMES="missing_mediaFiles_Name.txt"
MISSING_FILEPATHS="missing_mediaFiles_NamePath.txt"

set -e
#set -x

find "$ORIGIN_PATH" -type f | sort -u | grep -viE "$REGEXP_IGNORED_PATTERN" 2>/dev/null | grep -iE "$REGEXP_PATTERN" \
    > "$ORIGIN_PATH/$INDEX_FILENAME"
echo "Generado Index en Origen: $ORIGIN_PATH/$INDEX_FILENAME"

find "$DEST_PATH" -type f | sort -u | grep -viE "$REGEXP_IGNORED_PATTERN" 2>/dev/null | grep -iE "$REGEXP_PATTERN" \
    > "$DEST_PATH/$INDEX_FILENAME"
echo "Generado Index en Destino: $DEST_PATH/$INDEX_FILENAME"

comm -13 <(awk -F/ '{print $NF}' "$ORIGIN_PATH/$INDEX_FILENAME" | sort -u) <(awk -F/ '{print $NF}' "$DEST_PATH/$INDEX_FILENAME" | sort -u) \
    > "$ORIGIN_PATH/$MISSING_FILENAMES"
echo "Generada lista de archivos faltantes en Origen: $ORIGIN_PATH/$MISSING_FILENAMES"

comm -23 <(awk -F/ '{print $NF}' "$ORIGIN_PATH/$INDEX_FILENAME" | sort -u) <(awk -F/ '{print $NF}' "$DEST_PATH/$INDEX_FILENAME"| sort -u) \
    > "$DEST_PATH/$MISSING_FILENAMES"
echo "Generada lista de archivos faltantes en Destino: $DEST_PATH/$MISSING_FILENAMES"

if [ ! -s "$DEST_PATH/$MISSING_FILENAMES" ]; then
    echo "No se han encontraron archivos faltantes en el Destino."
    exit 0
fi

[ -f "$DEST_PATH/$MISSING_FILEPATHS" ] && rm "$DEST_PATH/$MISSING_FILEPATHS"
touch "$DEST_PATH/$MISSING_FILEPATHS"
while read -r fileName; do
    echo "$fileName :"
    awk -F/ -v fileName="$fileName" '$NF == fileName { print }' "$ORIGIN_PATH/$INDEX_FILENAME" | tee -a "$DEST_PATH/$MISSING_FILEPATHS"
done < "$DEST_PATH/$MISSING_FILENAMES"
