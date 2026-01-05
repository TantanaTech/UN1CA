#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

MODEL="$1"
CSC="$2"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> Extracting Firmware for $MODEL ($CSC)..."
mkdir -p "$FW_PATH"

# Download scriptinin kaydettiği isimle tam eşleşmeli
ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"

if [ ! -f "$ZIP_FILE" ]; then
    echo "!! HATA: Firmware dosyası bulunamadı: $ZIP_FILE"
    exit 1
fi

echo "-> Unzipping firmware..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

# BL ve AP tar dosyalarını bul
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$BL_TAR" ] || [ -z "$AP_TAR" ]; then
    echo "!! HATA: BL veya AP dosyaları bulunamadı!"
    exit 1
fi

echo "-> Extracting images..."
EXTRACT_FILE_FROM_TAR "$AP_TAR" "system.img" "$FW_PATH"
EXTRACT_FILE_FROM_TAR "$AP_TAR" "vendor.img" "$FW_PATH"
EXTRACT_FILE_FROM_TAR "$AP_TAR" "boot.img" "$FW_PATH"
EXTRACT_FILE_FROM_TAR "$BL_TAR" "vbmeta.img" "$FW_PATH"

# Eğer dosyalar system/system içindeyse, yukarı taşı
if [ -d "$FW_PATH/system/system" ]; then
    echo "-> Fixing double system directory structure..."
    mv "$FW_PATH/system/system/"* "$FW_PATH/system/"
    rm -rf "$FW_PATH/system/system"
fi

# Vendor için de aynısını kontrol edelim
if [ -d "$FW_PATH/vendor/vendor" ]; then
    echo "-> Fixing double vendor directory structure..."
    mv "$FW_PATH/vendor/vendor/"* "$FW_PATH/vendor/"
    rm -rf "$FW_PATH/vendor/vendor"
fi

touch "$FW_PATH/.extracted"
echo ">> Extraction complete!"
