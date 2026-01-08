#!/usr/bin/env bash
set -e

# Manuel olarak yolları tanımlıyoruz
ODIN_PATH="out/odin/SM-A047F_TUR"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"

echo "== A04s Firmware Hazırlanıyor =="
mkdir -p "$ODIN_PATH"

if ! command -v gdown >/dev/null 2>&1; then
    pip install gdown
fi

# Firmware'i doğru klasöre indir
if [ ! -f "$OUTNAME" ]; then
    gdown --id "1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-" -O "$OUTNAME"
fi

# make_rom.sh'ın indirme bittiğini anlaması için bu dosya ŞART
echo "A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "Dosya hazır: $OUTNAME"
