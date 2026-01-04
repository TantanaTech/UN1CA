#!/usr/bin/env bash

# -----------------------------
# Minimal Firmware Downloader
# (Samloader removed)
# -----------------------------

source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1
source "$TOOLS_DIR/venv/bin/activate" || exit 1

FORCE=false
MODEL=""
CSC=""
LATEST_FIRMWARE=""
ZIP_FILE=""

# --- Google Drive direct firmware link ---
DOWNLOAD_URL="https://drive.usercontent.google.com/download?id=1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-&authuser=0"


PRINT_USAGE() {
    echo "Usage: download_fw [options] <MODEL> <CSC>"
    echo " -f, --force  : Force download even if already exists"
}

if [ "$#" -lt 2 ]; then
    PRINT_USAGE
    exit 1
fi

# Parse args
while [ "$#" -gt 0 ]; do
    case "$1" in
        -f|--force)
            FORCE=true
            ;;
        *)
            if [ -z "$MODEL" ]; then
                MODEL="$1"
            elif [ -z "$CSC" ]; then
                CSC="$1"
            else
                echo "Unknown argument: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

if [ -z "$MODEL" ] || [ -z "$CSC" ]; then
    PRINT_USAGE
    exit 1
fi

ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

mkdir -p "$ODIN_PATH"
mkdir -p "$FW_PATH"

echo "- Firmware folder: $ODIN_PATH"

# Dummy version tag since samloader is removed
LATEST_FIRMWARE="DRIVE-LINK-FIRMWARE"

# Skip if not forced and already downloaded
if ! $FORCE && [ -f "$ODIN_PATH/.downloaded" ]; then
    echo "! Firmware already downloaded (use -f to force)"
    exit 0
fi

echo "- Downloading firmware from Google Drive..."

ZIP_FILE="$ODIN_PATH/firmware.zip"

wget -q \
    --show-progress \
    "$DOWNLOAD_URL" \
    -O "$ZIP_FILE"

if [ ! -f "$ZIP_FILE" ]; then
    echo "! Download failed"
    exit 1
fi

echo "- Extracting firmware.zip..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH" || exit 1
rm -f "$ZIP_FILE"

# --- MD5 Verification ---
VERIFY_ODIN_PACKAGES() {
    local f FILE_NAME LENGTH STORED_HASH CALCULATED_HASH

    while IFS= read -r f; do
        FILE_NAME="$(basename "$f")"
        echo "- Verifying $FILE_NAME..."

        FILE_NAME="${FILE_NAME%.md5}"

        LENGTH=$((32 + 2 + ${#FILE_NAME} + 1))
        STORED_HASH="$(tail -c "$LENGTH" "$f" | cut -d ' ' -f1)"

        if [[ ${#STORED_HASH} != 32 ]]; then
            echo "! Invalid or missing MD5 section"
            exit 1
        fi

        CALCULATED_HASH="$(head -c-"$LENGTH" "$f" | md5sum | cut -d ' ' -f1)"

        if [[ "$STORED_HASH" != "$CALCULATED_HASH" ]]; then
            echo "! File is corrupted: $FILE_NAME"
            exit 1
        fi

        echo "  ✔ OK"
    done < <(find "$ODIN_PATH" -type f -name "*.md5")
}

echo "- Verifying extracted ODIN packages..."
VERIFY_ODIN_PACKAGES || exit 1


echo "$LATEST_FIRMWARE" > "$ODIN_PATH/.downloaded"

echo "✔ Firmware ready in:"
echo "  $ODIN_PATH"

deactivate
exit 0
