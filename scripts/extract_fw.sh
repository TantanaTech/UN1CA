#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

MODEL="${1:-SM-A047F}"
CSC="${2:-TUR}"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> Extracting Firmware for $MODEL ($CSC)..."
mkdir -p "$FW_PATH"

ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"

if [ ! -f "$ZIP_FILE" ]; then
    echo "!! HATA: Firmware dosyası bulunamadı!"
    exit 1
fi

echo "-> Unzipping firmware..."
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

# AP ve BL dosyalarını bul
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)

echo "-> Extracting images from TAR packages..."
# Samsung tar dosyalarından imajları ayıkla (lz4 desteğiyle)
for img in "system.img" "vendor.img" "product.img" "boot.img"; do
    EXTRACT_FILE_FROM_TAR "$AP_TAR" "$img" "$FW_PATH" || echo "$img AP içinde bulunamadı, devam ediliyor..."
done

EXTRACT_FILE_FROM_TAR "$BL_TAR" "vbmeta.img" "$FW_PATH"

# KRİTİK: İmajlar hala .lz4 formatındaysa onları açmalıyız
cd "$FW_PATH"
for f in *.lz4; do
    if [ -f "$f" ]; then
        echo "-> Decompressing $f..."
        lz4 -d "$f" "${f%.lz4}" && rm "$f"
    fi
done

# UN1CA'nın paketleme için beklediği yere kopyala
mkdir -p "$WORK_DIR"
cp *.img "$WORK_DIR/" 2>/dev/null || true

touch "$FW_PATH/.extracted"
echo ">> Extraction complete! Images ready in $WORK_DIR"
