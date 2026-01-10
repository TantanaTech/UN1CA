#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

# Klasör yollarını loglara yazdırarak kontrol edelim
ODIN_PATH="$ODIN_DIR/SM-A047F_TUR"
FW_PATH="$FW_DIR/SM-A047F_TUR"

echo ">> Arama yolu: $ODIN_PATH"
ls -R "$ODIN_PATH" # İçeride ne var logda görelim

# AP paketini daha geniş bir arama ile bulalım
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$AP_TAR" ]; then
    echo "!! HATA: AP Tar paketi bulunamadı. İndirme adımı başarısız olmuş olabilir."
    exit 1
fi

echo "-> Bulunan Paket: $AP_TAR"
echo "-> İmajlar çıkarılıyor..."

# Dosyayı doğrudan çıkartalım
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4" || { echo "Tar başarısız"; exit 1; }

# LZ4'leri imaja çevir
cd "$FW_PATH"
for f in *.lz4; do
    lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
done

# Dosyaları WORK_DIR'e TAŞI
mkdir -p "$WORK_DIR"
mv -v *.img "$WORK_DIR/"
