#!/usr/bin/env bash

# -----------------------------
# Google Drive Firmware Downloader
# (SAMLOADER tamamen kaldırıldı)
# -----------------------------

source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1
source "$TOOLS_DIR/venv/bin/activate" || exit 1

# Sabit MODEL ve CSC
MODEL="SM-A047F"
CSC="TUR"

# Google Drive File ID
FILE_ID="1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-"
DOWNLOAD_URL="https://drive.google.com/uc?export=download&id=${FILE_ID}"

# Çıktı klasörleri
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

mkdir -p "$ODIN_PATH"
mkdir -p "$FW_PATH"

echo "==================================="
echo "   Firmware Downloader (Drive)"
echo "==================================="
echo "- Target Model: $MODEL"
echo "- Target CSC:   $CSC"
echo "- Odin Path:    $ODIN_PATH"

LATEST_FIRMWARE="DRIVE-FIRMWARE"

echo "- Downloading firmware from Google Drive..."
ZIP_FILE="$ODIN_PATH/firmware.zip"

# Google Drive büyük dosya indirme fix
wget --no-check-certificate \
     "https://drive.google.com/uc?export=download&id=${FILE_ID}" \
     -O "$ZIP_FILE" -q --show-progress

if [ ! -s "$ZIP_FILE" ]; then
    echo "! Download FAILED (file is empty)"
    exit 1
fi

# Google Drive bazen HTML döndürür, ZIP olmaz → kontrol
if ! unzip -t "$ZIP_FILE" >/dev/null 2>&1; then
    echo "! ERROR: File is not a valid ZIP."
    echo "! Google Drive direkt HTML sayfası indirmiş."
    echo "! Çözüm: 'confirm=' token'lı indirme gerekiyor."
    exit 1
fi

echo "- Extracting firmware..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH" || exit 1
rm -f "$ZIP_FILE"

echo "- Verifying extracted ODIN packages..."

VERIFY_ODIN_PACKAGES() {
    local f FILE_NAME LENGTH STORED_HASH CALCULATED_HASH

    while IFS= read -r f; do
        FILE_NAME="$(basename "$f")"
        echo "  * Checking $FILE_NAME"

        FILE_NAME="${FILE_NAME%.md5}"
        LENGTH=$((32 + 2 + ${#FILE_NAME} + 1))

        STORED_HASH="$(tail -c "$LENGTH" "$f" | cut -d ' ' -f1)"
        CALCULATED_HASH="$(head -c-"$LENGTH" "$f" | md5sum | cut -d ' ' -f1)"

        if [[ "$STORED_HASH" != "$CALCULATED_HASH" ]]; then
            echo "! MD5 FAILED: $FILE_NAME"
            exit 1
        fi

        echo "    ✔ OK"
    done < <(find "$ODIN_PATH" -type f -name "*.md5")
}

VERIFY_ODIN_PACKAGES || exit 1

echo "$LATEST_FIRMWARE" > "$ODIN_PATH/.downloaded"

echo "==================================="
echo "✔ Firmware ready!"
echo "→ $ODIN_PATH"
echo "==================================="

deactivate
exit 0
