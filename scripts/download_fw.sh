#!/usr/bin/env bash
set -e

# Tam klasör yolu (UN1CA'nın beklediği format)
ODIN_PATH="out/odin/SM-A047F_TUR"
OUTNAME="$ODIN_PATH/A047F_Firmware.zip"

echo "== A04s Firmware Indirici =="
mkdir -p "$ODIN_PATH"

if ! command -v gdown >/dev/null 2>&1; then pip install gdown; fi

# Firmware'i doğrudan klasörün içine indir
gdown --id "1C9GtYTn1EZ4sQN7qfJeWN6gxDj_WbgY-" -O "$OUTNAME"

# make_rom.sh'a "Dosya burada" işareti ver
echo "A047FXXSCEYI1" > "$ODIN_PATH/.downloaded"
echo "Indirme basarili: $OUTNAME"
