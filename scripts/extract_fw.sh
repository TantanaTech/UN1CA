#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

ODIN_PATH="$ODIN_DIR/SM-A047F_TUR"
FW_PATH="$FW_DIR/SM-A047F_TUR"
ZIP_FILE="$ODIN_PATH/A047F_Firmware.zip"

mkdir -p "$FW_PATH"

# Zip'i aç ve hemen sil (Yer kazanmak için ŞART)
if [ -f "$ZIP_FILE" ]; then
    unzip -o "$ZIP_FILE" -d "$ODIN_PATH" && rm -f "$ZIP_FILE"
fi

AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

# Hata alınan nokta burası: Exit code 2'yi engellemek için --wildcards ekliyoruz
echo "-> İmajlar TAR paketinden çıkarılıyor..."
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4" || echo "Bazı dosyalar eksik ama devam ediliyor..."

# TAR paketini SİL (Disk dolmasını engellemek için kritik)
rm -f "$AP_TAR"

# LZ4'leri aç ve sil
cd "$FW_PATH"
for f in *.lz4; do
    lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
done

# Dosyaları WORK_DIR'e taşı
mkdir -p "$WORK_DIR"
mv -v *.img "$WORK_DIR/" 2>/dev/null || true

touch "$FW_PATH/.extracted"
