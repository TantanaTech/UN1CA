#!/usr/bin/env bash

# Gerekli araçları dahil et (Unica yapısı için)
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

MODEL="$1"
CSC="$2"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

# 1. Klasör Hazırlığı
echo ">> Extracting Firmware for $MODEL ($CSC)..."
mkdir -p "$FW_PATH"

# 2. Zip Dosyasını Aç
ZIP_FILE="$ODIN_PATH/firmware.zip"
if [ ! -f "$ZIP_FILE" ]; then
    echo "!! HATA: firmware.zip bulunamadı! Yol: $ZIP_FILE"
    exit 1
fi

echo "-> Unzipping firmware..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

# 3. BL ve AP Dosyalarını Tespit Et
# Samsung dosyaları genelde BL_... ve AP_... ile başlar
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$BL_TAR" ] || [ -z "$AP_TAR" ]; then
    echo "!! HATA: BL veya AP tar dosyaları zip içinden çıkmadı!"
    exit 1
fi

# 4. Gerekli İmajları Ayıkla (System, Vendor, Boot vb.)
echo "-> Extracting images from TAR files..."

# AP içinden sistem dosyalarını çıkar
# EXTRACT_FILE_FROM_TAR fonksiyonu Unica'nın orijinal fonksiyonudur
EXTRACT_FILE_FROM_TAR "$AP_TAR" "system.img" "$FW_PATH"
EXTRACT_FILE_FROM_TAR "$AP_TAR" "vendor.img" "$FW_PATH"
EXTRACT_FILE_FROM_TAR "$AP_TAR" "boot.img" "$FW_PATH"

# BL içinden vbmeta gibi güvenlik dosyalarını çıkar
EXTRACT_FILE_FROM_TAR "$BL_TAR" "vbmeta.img" "$FW_PATH"

# 5. İşlemi Onayla
touch "$FW_PATH/.extracted"
echo ">> Extraction complete! Files are in $FW_PATH"
