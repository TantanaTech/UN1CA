#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

ODIN_PATH="out/odin/SM-A047F_TUR"
FW_PATH="out/firmware/SM-A047F_TUR"
WORK_DIR="out/target/a04s/work_dir"

# ÖNEMLİ: Eğer dosyalar zaten taşınmışsa, hata vermeden bitir
if [ -f "$WORK_DIR/system.img" ] || [ -f "$WORK_DIR/super.img" ]; then
    echo ">> Dosyalar zaten ayıklanmış ve hazır. İşlem atlanıyor."
    exit 0
fi

echo ">> Ayıklama Başlatılıyor..."
mkdir -p "$FW_PATH" "$WORK_DIR"

# AP Paketini Bul
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$AP_TAR" ]; then
    # Eğer AP yoksa ama zaten ayıklanmışsa yukarıdaki kontrol sayesinde buraya düşmez.
    # Buraya düşüyorsa gerçekten bir sorun vardır.
    echo "!! HATA: AP Tar paketi bulunamadı!"
    ls -R "$ODIN_PATH"
    exit 1
fi

# İmajları Çıkar
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4"

# LZ4'leri Aç ve Sil
cd "$FW_PATH"
for f in *.lz4; do
    lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
done

# Dosyaları Taşı ve Kaynağı Temizle
cd - > /dev/null
mv -v "$FW_PATH"/*.img "$WORK_DIR/"
rm -f "$AP_TAR" # Sadece taşıma başarılı olduktan sonra siler

touch "$FW_PATH/.extracted"
echo ">> İşlem Tamam!"
