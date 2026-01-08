#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

# Değişkenleri garantiye alıyoruz
MODEL="${1:-SM-A047F}"
CSC="${2:-TUR}"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> A04s One UI 7 İmajları Ayıklanıyor..."
mkdir -p "$FW_PATH"

ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)

echo "-> TAR paketlerinden büyük imajlar (lz4) çıkarılıyor..."
# Tüm kritik imajları listeye ekledik
for img in "system.img.lz4" "vendor.img.lz4" "product.img.lz4" "boot.img.lz4"; do
    EXTRACT_FILE_FROM_TAR "$AP_TAR" "$img" "$FW_PATH" || echo "$img AP paketinde bulunamadı."
done

EXTRACT_FILE_FROM_TAR "$BL_TAR" "vbmeta.img.lz4" "$FW_PATH" || echo "vbmeta BL paketinde bulunamadı."

# LZ4 dosyalarını gerçek imajlara (.img) dönüştür
echo "-> LZ4 sıkıştırması açılıyor..."
cd "$FW_PATH"
for f in *.lz4; do
    if [ -f "$f" ]; then
        echo "-> Decompressing $f..."
        lz4 -d "$f" "${f%.lz4}" && rm "$f"
    fi
done

# build_flashable_zip.sh'in dosyaları bulması için WORK_DIR'e kopyalıyoruz
mkdir -p "$WORK_DIR"
cp *.img "$WORK_DIR/" 2>/dev/null || true

touch "$FW_PATH/.extracted"
echo ">> İmajlar başarıyla hazırlandı: $WORK_DIR"
