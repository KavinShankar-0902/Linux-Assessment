#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found!"
    exit 1

fi


> "$OUTPUT_FILE"
while IFS= read -r line
do
    case "$line" in
        *\"frame.time\"*)
            echo "$line" >> "$OUTPUT_FILE"
            ;;
        *\"wlan.fc.type\"*)
            echo "$line" >> "$OUTPUT_FILE"
            ;;
        *\"wlan.fc.subtype\"*)
            echo "$line" >> "$OUTPUT_FILE"
            ;;
    esac
done < "$INPUT_FILE"
echo "Extraction completed. Check output.txt"
