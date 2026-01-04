#!/usr/bin/env bash

# -----------------------------------------
# Google Drive Firmware Downloader (FIXED)
# Confirm-token bypass + zero samloader
# -----------------------------------------

source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1
source "$TOOLS_DIR/venv/bin/activate" || exit 1

MODEL="SM-A047F"
CSC="TUR"

FILE_ID="1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-"
BASE_URL="https://drive.google.com/uc?export=download"

ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

mkdir -p "$ODIN_PATH" "$FW_PATH"

echo "======================================"
echo "  Google Drive Firmware Downloader"
echo "======================================"
echo "- Model: $MODEL"
echo "- CSC:   $CSC"
echo "- Output: $ODIN_PATH"

ZIP_FILE="$ODIN_PATH/firmware.zip"

echo "- Step 1: Requesting download token..."

CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies \
    "${BASE_URL}&id=${FILE_ID}" -O- | \
    sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')

if [ -z "$CONFIRM" ]; then
    echo "! Failed to get confirm token."
    exit 1
fi

echo "- Token acquired: $CONFIRM"

echo "- Step 2: Downloading firmware..."

wget --load-cookies /tmp/cookies.txt \
    "${BASE_URL}&confirm=${CONFIRM}&id=${FILE_ID}" \
    -O "$ZIP_FILE" --show-progress -q

rm -f /tmp/cookies.txt

if [ ! -s "$ZIP_FILE" ]; then
    echo "! ERROR: Download failed or file empty!"
    exit 1
fi

echo "- Step 3: Validating ZIP file..."

if ! unzip -t "$ZIP_FILE" >/dev/null 2>&1; then
    echo "! ERROR: Downloaded file is NOT a valid ZIP."
    exit 1
fi

echo "- Extracting..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH" >/dev/null
rm -f "$ZIP_FILE"

echo "- Verifying ODIN .md5 files..."

VERIFY_ODIN_PACKAGES() {
    while IFS= read -r f; do
        FILE_NAME="$(basename "$f")"
        echo "  * Checking $FILE_NAME"

        NAME="${FILE_NAME%.md5}"
        LENGTH=$((32 + 2 + ${#NAME} + 1))

        STORED=$(tail -c "$LENGTH" "$f" | cut -d ' ' -f1)
        CURRENT=$(head -c-"$LENGTH" "$f" | md5sum | cut -d ' ' -f1)

        if [[ "$STORED" != "$CURRENT" ]]; then
            echo "! MD5 FAIL: $FILE_NAME"
            exit 1
        fi

        echo "    ✔ OK"
    done < <(find "$ODIN_PATH" -type f -name "*.md5")
}

VERIFY_ODIN_PACKAGES || exit 1

echo "DRIVE-FIRMWARE" > "$ODIN_PATH/.downloaded"

echo "======================================"
echo "✔ Firmware Ready!"
echo "→ $ODIN_PATH"
echo "======================================"

deactivate
exit 0
