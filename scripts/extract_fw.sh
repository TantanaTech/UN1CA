#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

MODEL="${1:-SM-A047F}"
CSC="${2:-TUR}"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> A04s One UI 7: Derin Ayıklama Başlatıldı..."
mkdir -p "$FW_PATH"

ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"
unzip -o "$ZIP_FILE" -d "$ODIN_PATH"

# AP ve BL paketlerini bul
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)

echo "-> TAR paketleri içindeki tüm LZ4 dosyaları dışarı aktarılıyor..."
# Spesifik isim aramak yerine tüm lz4'leri çıkartıyoruz (En garantisi bu)
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.lz4"
tar -xf "$BL_TAR" -C "$FW_PATH" --wildcards "vbmeta*.lz4"

echo "-> LZ4 sıkıştırmaları açılıyor..."
cd "$FW_PATH"
for f in *.lz4; do
    if [ ! -f "${f%.lz4}" ]; then
        echo "-> Decompressing: $f"
        lz4 -d "$f" "${f%.lz4}" && rm "$f"
    fi
done

# UN1CA'nın ve build_flashable_zip'in dosyaları bulması için kopyala
mkdir -p "$WORK_DIR"
cp -v *.img "$WORK_DIR/" 2>/dev/null || true

touch "$FW_PATH/.extracted"
echo ">> Ayıklama bitti. WORK_DIR içeriği:"
ls -lh "$WORK_DIR"
