#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

# Değişken boş gelirse varsayılan olarak A04s ve TUR ata
MODEL="${1:-SM-A047F}"
CSC="${2:-TUR}"

# Klasör yollarını netleştiriyoruz
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> Extracting Firmware for $MODEL ($CSC)..."
mkdir -p "$FW_PATH"

# Zip dosyasının adını ve yerini garantiye alıyoruz
ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"

if [ ! -f "$ZIP_FILE" ]; then
    # Eğer o klasörde yoksa ana dizine de bak (hata payını azaltmak için)
    if [ -f "A047F_Firmware.zip" ]; then
        mkdir -p "$ODIN_PATH"
        mv "A047F_Firmware.zip" "$ZIP_FILE"
    else
        echo "!! HATA: Firmware dosyası bulunamadı: $ZIP_FILE"
        exit 1
    fi
fi

echo "-> Unzipping firmware..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

# Dosyaları ayıklama işlemi
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

# Klasör yapısı düzeltmeleri
if [ -d "$FW_PATH/system/system" ]; then
    mv "$FW_PATH/system/system/"* "$FW_PATH/system/"
    rm -rf "$FW_PATH/system/system"
fi

touch "$FW_PATH/.extracted"
echo ">> Extraction complete!"
