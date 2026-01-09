#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

MODEL="${1:-SM-A047F}"
CSC="${2:-TUR}"
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
FW_PATH="$FW_DIR/${MODEL}_${CSC}"

echo ">> Disk Dostu Ayıklama Başlatıldı..."
mkdir -p "$FW_PATH"

ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"
if [ -f "$ZIP_FILE" ]; then
    echo "-> Firmware Zip açılıyor..."
    unzip -o "$ZIP_FILE" -d "$ODIN_PATH"
    rm -f "$ZIP_FILE"  # DİSKİ BOŞALT: Zip ile işimiz bitti
fi

AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)
BL_TAR=$(find "$ODIN_PATH" -name "BL_*.tar.md5" | head -n 1)

# Sadece ihtiyacımız olan lz4 dosyalarını tek tek çıkart ve TAR'ı sil
echo "-> İmajlar ayıklanıyor..."
for img in "system.img.lz4" "vendor.img.lz4" "product.img.lz4" "boot.img.lz4"; do
    tar -xf "$AP_TAR" -C "$FW_PATH" "$img" 2>/dev/null && echo "-> $img çıktı."
done
rm -f "$AP_TAR" # DİSKİ BOŞALT: 5-8 GB yer açar

tar -xf "$BL_TAR" -C "$FW_PATH" "vbmeta.img.lz4" 2>/dev/null
rm -f "$BL_TAR"  # DİSKİ BOŞALT

# LZ4 dosyalarını aç ve hemen lz4 versiyonunu sil
echo "-> LZ4 açılıyor..."
cd "$FW_PATH"
for f in *.lz4; do
    if [ -f "$f" ]; then
        lz4 -d "$f" "${f%.lz4}" && rm -v "$f" # DİSKİ BOŞALT: Sıkıştırılmışı sil
    fi
done

# build_flashable_zip için dosyaları taşı
mkdir -p "$WORK_DIR"
mv -v *.img "$WORK_DIR/" 2>/dev/null || true # cp yerine mv kullanarak yer kazan

touch "$FW_PATH/.extracted"
echo ">> Ayıklama ve Temizlik Tamamlandı!"
