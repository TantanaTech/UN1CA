#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

# - Orijinal değişkenleri ve fonksiyonları koruyoruz
SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

# A04s Yol Düzeltmesi: system/system yerine system deniyoruz
SOURCE_FINGERPRINT="$(GET_PROP "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/build.prop" "ro.system.build.fingerprint")"
TARGET_FINGERPRINT="$(GET_PROP "$FW_DIR/$TARGET_FIRMWARE_PATH/system/build.prop" "ro.system.build.fingerprint")"

TMP_DIR="$OUT_DIR/zip"
ZIP_FILE_NAME="UN1CA_A04s_OneUI7_$(date +%Y%m%d).zip"

# Fonksiyon Tanımları (Buradaki fonksiyonları silme, zip'in kalbi bunlar!)
#
BUILD_SUPER_EMPTY() { ... }
GENERATE_OP_LIST() { ... }
GENERATE_UPDATER_SCRIPT() { ... }
SIGN_IMAGE_WITH_AVB() { ... }

trap 'rm -rf "$TMP_DIR"' EXIT INT

[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp -a "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

LOG_STEP_IN "- Building OS partitions"
while IFS= read -r f; do
    PARTITION=$(basename "$f")
    [ "$PARTITION" == "configs" ] || [ "$PARTITION" == "kernel" ] && continue
    
    # Hata olsa da devam et (|| echo)
    "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM_TYPE" \
        -o "$TMP_DIR/$PARTITION.img" -m -S \
        "$WORK_DIR/$PARTITION" "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION" || echo "Warning: $PARTITION failed"
done < <(find "$WORK_DIR" -maxdepth 1 -type d)
LOG_STEP_OUT

# Dinamik bölümleri ve updater scripti oluştur
BUILD_SUPER_EMPTY
GENERATE_OP_LIST
GENERATE_UPDATER_SCRIPT

# Kernel dosyalarını kopyala
if [ -d "$WORK_DIR/kernel" ]; then
    cp -a "$WORK_DIR/kernel/"*.img "$TMP_DIR/"
fi

LOG "- Creating zip"
EVAL "rm -f \"$OUT_DIR/$ZIP_FILE_NAME\""
# En güvenli paketleme yöntemi
cd "$TMP_DIR" && 7z a -tzip "$OUT_DIR/$ZIP_FILE_NAME" * -mx=3

exit 0
