#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"source_dir\" \"backup_dir\" \".extension\""
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXTENSION="$3"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || {
        echo "Error: Failed to create backup directory."
        exit 1
    }
fi

FILES=("$SOURCE_DIR"/*"$EXTENSION")

if [ ! -e "${FILES[0]}" ]; then
    echo "No files with extension $EXTENSION found."
    exit 0
fi

BACKUP_COUNT=0
TOTAL_SIZE=0
export BACKUP_COUNT

echo "Files to be backed up:"

for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        SIZE=$(stat -c%s "$FILE")
        echo "$(basename "$FILE") - $SIZE bytes"

        DEST_FILE="$BACKUP_DIR/$(basename "$FILE")"

        if [ -f "$DEST_FILE" ]; then
            if [ "$FILE" -nt "$DEST_FILE" ]; then
                cp "$FILE" "$DEST_FILE"
            else
                continue
            fi
        else
            cp "$FILE" "$DEST_FILE"
        fi

        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
done

REPORT_FILE="$BACKUP_DIR/backup_report.log"

{
    echo "Backup Summary Report"
    echo "----------------------"
    echo "Total files processed: $BACKUP_COUNT"
    echo "Total size backed up: $TOTAL_SIZE bytes"
    echo "Backup location: $BACKUP_DIR"
    echo "Date: $(date)"
} > "$REPORT_FILE"

echo "Backup completed. Report saved at $REPORT_FILE"

