#!/usr/bin/env bash
set -e

# === CONFIG ===
# Yeni paylaştığın çalışan link ID'si
FILE_ID="13g7bs8VnOPeOc8gUnnOBINSp5ekzAUvb"
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

# Yeni ID ile indirme denemesi. 
# --proxy veya --fuzzy gibi parametreler eklemiyoruz, gdown genellikle --id ile daha stabil çalışır.
gdown --id "$FILE_ID" -O "$OUTNAME"

if [ ! -f "$OUTNAME" ]; then
    echo "ERROR: Download failed!"
    exit 1
fi

# Extract scriptinin tanıması için işaret bırakıyoruz
echo "A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "Download complete and verified."
