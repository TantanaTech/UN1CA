#!/usr/bin/env bash

# --------------------------------------
# Minimal Firmware Downloader (No Drive)
# --------------------------------------

FORCE=false
MODEL=""
CSC=""

# Yeni eklediğin direkt indirme linki
DOWNLOAD_URL="https://s12.ooo/v2/IxJCDiMnLiwSJSk2AzA8MTwwAjEjCB4lFzssIDs2ByAzMUEgOzEUQDMQMCMBOyw/LghBBx4XKTwzMTMGAzECHgMwKQ4vFjNALxEdPzULIj8uJzYALgAzJTxAQQYhAC4vEgc+CwkvICAPFyktNBEHPAEHHgcuBykjDxszKTIIHyQ7Ox4jAwMvES84BkIeCzwGHgM8FCMkNDEjCxVACTghHzInDQYuFx8rIwAvJCFAMxE8EQY5NRshDjURPho0ES8kNRYhOR44LwsJEQc5NBsjKyEAPg4hAAYsLjgeLDQRHg4yJTMsMiUNKzwAPh8mGzk5FyUzDTUHQQEuByADISxBIwMnOUANQAokMzYCICMXPjkDFzA1CS8pDTsxHhwzQAZCOzEHHjMsNCsNMT4eODAeHgk7CDkeFi4nODAzLzssPiAjFg1AMywpPDsxHgcXOzYGOAAhKTw/FD01OCBCJgQwBx4bOxQ7BywAMkAHIxI7AiQ8ES8/MwApIwE7BgQNFx4tPEAhBiMHAhYjOAZCIwM0AB4kPAABFjw/AQ0TEw=="

PRINT_USAGE() {
    echo "Usage: download_fw [options] <MODEL> <CSC>"
    echo " -f, --force  : Force download even if already exists"
}

# -----------------------------
# Parse args
# -----------------------------
if [ "$#" -lt 2 ]; then
    PRINT_USAGE
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -f|--force) FORCE=true ;;
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

# ODIN_PATH'in doğru olduğundan emin olalım
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
mkdir -p "$ODIN_PATH"

# Dosya ismini extract_fw'nin aradığı isim yapalım
ZIP_FILE="$ODIN_PATH/firmware.zip"
# SKİP İF EXİSTİNT
if ! $FORCE && [ -f "$ODIN_PATH/.downloaded" ]; then
    echo "! Firmware already downloaded"
    exit 0
fi

echo "- Downloading firmware..."
# Dosyayı direkt ZIP_FILE olarak kaydediyoruz
wget -q --show-progress "$DOWNLOAD_URL" -O "$ZIP_FILE"

if [ ! -f "$ZIP_FILE" ]; then
    echo "! DOWNLOAD FAILED"
    exit 1
fi

# ÖNEMLİ: unzip işlemini burada yapmıyoruz, extract_fw.sh zaten yapıyor.
# Sadece .downloaded dosyasını oluşturuyoruz.
echo "A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"

echo "✔ Firmware downloaded and ready for extraction."
exit 0
