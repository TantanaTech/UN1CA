#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

# Klasör tanımları
ODIN_PATH="out/odin/SM-A047F_TUR"
FW_PATH="out/firmware/SM-A047F_TUR"
WORK_DIR="out/target/a04s/work_dir"

echo ">> Mevcut Durum Kontrol Ediliyor..."
mkdir -p "$FW_PATH" "$WORK_DIR"

# 1. ZIP Dosyasını Bul ve Aç
ZIP_FILE=$(find "$ODIN_PATH" -name "*.zip" | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    echo "-> ZIP bulundu: $ZIP_FILE. Açılıyor..."
    unzip -o "$ZIP_FILE" -d "$ODIN_PATH"
    # DİSK YERİ İÇİN KRİTİK: Açtıktan sonra zip'i sil
    rm -f "$ZIP_FILE"
else
    echo "!! HATA: ZIP dosyası bulunamadı. İndirme aşamasını kontrol et."
    ls -R out/
    exit 1
fi

# 2. AP Paketini Şimdi Ara (ZIP açıldıktan sonra oluşmalı)
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$AP_TAR" ]; then
    echo "!! HATA: AP Tar paketi hala yok. ZIP içeriğini kontrol et:"
    ls -R "$ODIN_PATH"
    exit 1
fi

echo "-> Başarılı! AP Paketi: $AP_TAR"

# 3. İmajları Çıkar ve LZ4'ten Kurtar
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4"
rm -f "$AP_TAR" # Yer kazanmak için sil

cd "$FW_PATH"
for f in *.lz4; do
    lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
done

# 4. Dosyaları Taşı
mv *.img "$WORK_DIR/"
touch "$FW_PATH/.extracted"
echo ">> İşlem Tamam! Imajlar $WORK_DIR içinde."
