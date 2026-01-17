#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/firmware_utils.sh" || exit 1

ODIN_PATH="out/odin/SM-A047F_TUR"
FW_PATH="out/firmware/SM-A047F_TUR"
WORK_DIR="out/target/a04s/work_dir"

echo ">> Kontrol Başlatıldı..."
mkdir -p "$FW_PATH" "$WORK_DIR"

# 1. ADIM: Eğer imajlar zaten WORK_DIR içindeyse işlemi atla (Hız kazandırır)
if [ -f "$WORK_DIR/system.img" ]; then
    echo ">> Dosyalar zaten hazır, ayıklama atlanıyor."
    exit 0
fi

# 2. ADIM: ZIP dosyasını bul ve mutlaka AÇ
ZIP_FILE=$(find "$ODIN_PATH" -name "*.zip" | head -n 1)
if [ -f "$ZIP_FILE" ]; then
    echo "-> ZIP bulundu, açılıyor: $ZIP_FILE"
    unzip -o "$ZIP_FILE" -d "$ODIN_PATH"
    # DİSK YERİ İÇİN: ZIP'i açtıktan sonra silebilirsin ama önce açıldığından emin olmalısın
fi

# 3. ADIM: AP paketini şimdi ara (Açıldıktan sonra burada olmalı)
AP_TAR=$(find "$ODIN_PATH" -name "AP_*.tar.md5" | head -n 1)

if [ -z "$AP_TAR" ]; then
    echo "!! HATA: AP paketi hala bulunamadı. ZIP içeriği hatalı olabilir."
    ls -R "$ODIN_PATH"
    exit 1
fi

echo "-> AP Paketi işleniyor: $AP_TAR"

# 4. ADIM: İmajları çıkar ve lz4'ten kurtar
tar -xf "$AP_TAR" -C "$FW_PATH" --wildcards "*.img.lz4"
cd "$FW_PATH"
for f in *.lz4; do
    lz4 -d "$f" "${f%.lz4}" && rm -f "$f"
done

# 5. ADIM: Dosyaları taşı ve temizle
cd - > /dev/null
mv -v "$FW_PATH"/*.img "$WORK_DIR/"
rm -f "$AP_TAR" # Yer açmak için silebilirsin

touch "$FW_PATH/.extracted"
echo ">> İşlem Başarıyla Tamamlandı!"
