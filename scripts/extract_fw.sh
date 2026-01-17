#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

# Klasörleri tam (absolute) yola yakın tanımlayalım
ODIN_PATH="out/odin/SM-A047F_TUR"
FW_PATH="out/firmware/SM-A047F_TUR"
WORK_DIR="out/target/a04s/work_dir"

echo ">> Mevcut Durum Kontrol Ediliyor..."
# Klasörleri temizce oluştur
mkdir -p "$FW_PATH"
mkdir -p "$WORK_DIR"

# 1. ZIP Dosyasını Aç
ZIP_FILE=$(find "$ODIN_PATH" -name "*.zip" | head -n 1)
if [ -f "$ZIP_FILE" ]; then
    echo "-> ZIP açılıyor: $ZIP_FILE"
    unzip -o "$ZIP_FILE" -d "$ODIN_PATH" && rm -f "$ZIP_FILE"
else
    # Eğer zip yoksa ama tar dosyaları zaten dışardaysa hata verme, devam et
    echo "-> ZIP bulunamadı, mevcut TAR dosyaları kontrol ediliyor..."
fi

# 2. AP Paketini Bul
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)
if [ -z "$AP_TAR" ]; then
    echo "!! HATA: AP Tar paketi yok!"
    ls -R "$ODIN_PATH"
    exit 1
fi

# 3. İmajları Çıkar (Disk dostu yöntem)
echo "-> TAR paketinden imajlar çıkarılıyor..."
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4" && rm -f "$AP_TAR"

# 4. LZ4 Decompress ve Anında Sil
echo "-> LZ4 dosyaları açılıyor..."
cd "$FW_PATH" || exit 1
for f in *.lz4; do
    if [ -f "$f" ]; then
        lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
    fi
done

# 5. Dosyaları Taşı (Hata almamak için geri dizine çıkıp tam yol kullanıyoruz)
echo "-> Dosyalar $WORK_DIR içine taşınıyor..."
cd - > /dev/null # Ana dizine geri dön
mv -v "$FW_PATH"/*.img "$WORK_DIR/" 2>/dev/null || true

# İşlem bitti işareti
touch "$FW_PATH/.extracted"
echo ">> İşlem Tamam! Imajlar başarıyla hazırlandı."
