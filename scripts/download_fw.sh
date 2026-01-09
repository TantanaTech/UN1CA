#!/usr/bin/env bash
set -e

ODIN_PATH="out/odin/SM-A047F_TUR"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"

echo "== A04s Firmware Hazırlanıyor =="
mkdir -p "$ODIN_PATH"

if ! command -v gdown >/dev/null 2>&1; then
    pip install gdown
fi

# ÖNEMLİ: link.txt dosyasındaki doğru ID buraya eklendi (1K_-v9tc...)
if [ ! -f "$OUTNAME" ]; then
    echo "-> Firmware indiriliyor..."
    gdown --id "1K_-v9tcg-aQDKWfG0Isl0Ee4YCCxYVWT" -O "$OUTNAME" --fuzzy
fi

# Bu dosya, extract_fw.sh scriptinin başlamasını sağlar
echo "A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "İndirme başarılı: $OUTNAME"
