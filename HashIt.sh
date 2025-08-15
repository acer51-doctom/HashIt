#!/bin/bash

# =========================
# hashit - compute selected checksums for a file
# =========================

# Default values
SAVE_FILE=""
ALGOS=()

# Function to display usage
usage() {
    echo "Usage: $0 [options] <file>"
    echo "Options:"
    echo "  --md5          Compute MD5 checksum"
    echo "  --sha1         Compute SHA1 checksum"
    echo "  --sha256       Compute SHA256 checksum"
    echo "  --sha512       Compute SHA512 checksum"
    echo "  --checksum     Compute POSIX cksum"
    echo "  -s, --save-file  Save results to files in <file>.<algo> format"
    exit 1
}

# Parse arguments
while [[ "$1" != "" ]]; do
    case $1 in
        --md5) ALGOS+=("md5") ;;
        --sha1) ALGOS+=("sha1") ;;
        --sha256) ALGOS+=("sha256") ;;
        --sha512) ALGOS+=("sha512") ;;
        --checksum) ALGOS+=("cksum") ;;
        -s|--save-file) SAVE_FILE="yes" ;;
        -h|--help) usage ;;
        *) 
            # Assume last argument is the file
            FILE="$1"
            ;;
    esac
    shift
done

# Check if file is provided
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Error: file not specified or does not exist."
    usage
fi

# If no algorithm is specified, default to all
if [ ${#ALGOS[@]} -eq 0 ]; then
    ALGOS=("md5" "sha1" "sha256" "sha512" "cksum")
fi

# Function to compute checksum
compute_hash() {
    local algo=$1
    local file=$2
    local sum=""

    case $algo in
        md5)
            if command -v md5sum &>/dev/null; then
                sum=$(md5sum "$file" | awk '{print $1}')
            else
                sum=$(md5 -q "$file")
            fi
            ;;
        sha1)
            if command -v sha1sum &>/dev/null; then
                sum=$(sha1sum "$file" | awk '{print $1}')
            else
                sum=$(shasum -a 1 "$file" | awk '{print $1}')
            fi
            ;;
        sha256)
            if command -v sha256sum &>/dev/null; then
                sum=$(sha256sum "$file" | awk '{print $1}')
            else
                sum=$(shasum -a 256 "$file" | awk '{print $1}')
            fi
            ;;
        sha512)
            if command -v sha512sum &>/dev/null; then
                sum=$(sha512sum "$file" | awk '{print $1}')
            else
                sum=$(shasum -a 512 "$file" | awk '{print $1}')
            fi
            ;;
        cksum)
            sum=$(cksum "$file" | awk '{print $1}')
            ;;
    esac

    echo "$algo: $sum"

    # Save to file if requested
    if [ "$SAVE_FILE" == "yes" ]; then
        ext="${file##*.}"
        base="${file%.*}"
        out_file="${base}.${ext}.${algo}"
        echo "$sum" > "$out_file"
    fi
}

# Main loop
for algo in "${ALGOS[@]}"; do
    compute_hash "$algo" "$FILE"
done
