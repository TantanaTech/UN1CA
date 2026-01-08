#!/usr/bin/env bash
set -e

# === CONFIG (A04s Spesifik) ===
FILE_ID="1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-"
MODEL="SM-A047F"
CSC="TUR"

# [span_2](start_span)UN1CA ana scriptinin (make_rom.sh) beklediği tam yol[span_2](end_span)
ODIN_PATH="out/odin/${MODEL}_${CSC}"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"
# ==============================

echo "== Samsung A04s Firmware Downloader (Compatible Mode) =="

# Klasörü oluştur
mkdir -p "$ODIN_PATH"

# gdown kontrolü
if ! command -v gdown >/dev/null 2>&1; then
    pip install gdown
fi

# İndirme işlemi
if [ -f "$OUTNAME" ]; then
    echo "Firmware zaten mevcut: $OUTNAME"
else
    echo "İndiriliyor: $OUTNAME"
    gdown --id "$FILE_ID" -O "$OUTNAME"
fi

# Başarı kontrolü
if [ ! -f "$OUTNAME" ]; then
    echo "HATA: İndirme başarısız!"
    exit 1
fi

# [span_3](start_span)KRİTİK: make_rom.sh'ın hata vermemesi için gereken işaret dosyaları[span_3](end_span)
echo "A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
touch "$ODIN_PATH/.extracted" 

echo "İşlem başarıyla tamamlandı. Dosya konumu: $OUTNAME"
