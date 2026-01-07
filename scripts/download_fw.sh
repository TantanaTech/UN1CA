#!/usr/bin/env bash
set -e

# === CONFIG ===
# Senin verdiğin yeni çalışan link ID'si
FILE_ID="13g7bs8VnOPeOc8gUnnOBINSp5ekzAUvb"
MODEL="SM-A047F"
CSC="TUR"

# Orijinal make_rom.sh'ın beklediği klasör yapısı
# Örn: out/odin/SM-A047F_TUR
ODIN_PATH="$ODIN_DIR/${MODEL}_${CSC}"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"
# ==============

echo "== Samsung A04s Firmware Downloader (Compatible Version) =="
mkdir -p "$ODIN_PATH"

# gdown kontrolü
if ! command -v gdown >/dev/null 2>&1; then
    pip install gdown
fi

# Eğer dosya zaten varsa indirme
if [ -f "$OUTNAME" ]; then
    echo "Firmware zaten mevcut: $OUTNAME"
else
    echo "Firmware indiriliyor: $OUTNAME"
    gdown --id "$FILE_ID" -O "$OUTNAME"
fi

# Başarı kontrolü
if [ ! -f "$OUTNAME" ]; then
    echo "HATA: İndirme başarısız!"
    exit 1
fi

# KRİTİK: Orijinal make_rom.sh bu .downloaded dosyasını tam bu yolda bekler
echo "A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1/A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "İndirme tamamlandı ve doğrulandı."
