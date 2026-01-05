#!/usr/bin/env bash

# --------------------------------------
# Minimal Firmware Downloader (No Drive)
# --------------------------------------

set -e

# === CONFIG ===
FILE_ID="1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-"
OUTNAME="A047F_Firmware.zip"
# ==============

echo "== Samsung A04s Firmware Downloader (gdown) =="

# Eğer dosya zaten varsa tekrar indirme
if [ -f "$OUTNAME" ]; then
    echo "Firmware already downloaded: $OUTNAME"
    echo "$OUTNAME" > .downloaded
    exit 0
fi

# gdown yoksa yükle
if ! command -v gdown >/dev/null 2>&1; then
    echo "gdown not found, installing..."
    pip install gdown
fi

echo "Downloading firmware via gdown..."
gdown --id "$FILE_ID" -O "$OUTNAME"

# Başarılı mı kontrol et
if [ ! -f "$OUTNAME" ]; then
    echo "ERROR: Download failed!"
    exit 1
fi

echo "Download complete: $OUTNAME"

# Build system’e bilgi ver
echo "$OUTNAME" > .downloaded
