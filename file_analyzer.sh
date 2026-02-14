#!/bin/bash

ERROR_LOG="errors.log"
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -k <keyword>     Keyword to search (required)
  -f <file>        Search keyword in specific file
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
EOF
}
search_directory() {
    local dir="$1"

    local keyword="$2"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            search_directory "$item" "$keyword"
        elif [ -f "$item" ]; then
            if grep -q "$keyword" "$item"; then
                echo "Match found in: $item"
            fi
        fi
    done
}




log_error() {
    echo "Error: $1" | tee -a "$ERROR_LOG"
}


if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi


while getopts ":d:k:f:" opt; do
    case $opt in
        d) DIRECTORY="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        \?) log_error "Invalid option: -$OPTARG"
            exit 1 ;;
    esac
done
if [ $# -eq 0 ]; then
    log_error "No arguments provided. Use --help for usage."
    exit 1
fi


if [[ -z "$KEYWORD" || ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then

    log_error "Invalid or empty keyword."
    exit 1
fi

if [[ -n "$DIRECTORY" ]]; then

    if [[ ! -d "$DIRECTORY" ]]; then
        log_error "Directory does not exist."
        exit 1
    fi

    echo "Searching recursively in directory: $DIRECTORY"
    search_directory "$DIRECTORY" "$KEYWORD"
    echo "Search completed with status: $?"


elif [[ -n "$FILE" ]]; then

    if [[ ! -f "$FILE" ]]; then
        log_error "File does not exist."
        exit 1
    fi

    echo "Searching in file: $FILE"

    while read -r line; do

        if [[ "$line" =~ $KEYWORD ]]; then
            echo "Match: $line"
        fi

    done <<< "$(cat "$FILE")"

    echo "Search completed with status: $?"
else
    log_error "Either -d or -f must be specified."
    exit 1
fi
