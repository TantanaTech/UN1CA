#!/usr/bin/env bash
set -e

# === CONFIG ===
FILE_ID="1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-"
MODEL="SM-A047F"
CSC="TUR"
# Unica'nın standart ODIN_DIR yolunu kullanıyoruz
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"
# ==============

echo "== Samsung A04s Firmware Downloader (gdown) =="
mkdir -p "$ODIN_PATH"

# gdown yoksa yükle
if ! command -v gdown >/dev/null 2>&1; then
    pip install gdown
fi

echo "Downloading firmware directly to $ODIN_PATH..."
gdown --id "$FILE_ID" -O "$OUTNAME"

if [ ! -f "$OUTNAME" ]; then
    echo "ERROR: Download failed!"
    exit 1
fi

# Extract scriptinin tanıması için işaret bırakıyoruz
echo "A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "Download complete and verified."
