#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TARGET_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$TARGET_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$TARGET_FIRMWARE")"

# A04s fingerprint okuma
if [ -f "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/build.prop" ]; then
    SOURCE_FINGERPRINT="$(GET_PROP "$FW_DIR/$SOURCE_FIRMWARE_PATH/system/build.prop" "ro.system.build.fingerprint")"
else
    SOURCE_FINGERPRINT="Samsung/A04s/OneUI7:15/Manual/Port"
fi

TMP_DIR="$OUT_DIR/zip"
ZIP_FILE_NAME="UN1CA_A04s_OneUI7_$(date +%Y%m%d).zip"

# Fonksiyonları orijinal halleriyle geri ekliyoruz
BUILD_SUPER_EMPTY() {
    local CMD="lpmake --metadata-size 65536 --super-name super --metadata-slots 2 --device super:$TARGET_SUPER_PARTITION_SIZE"
    CMD+=" --group $TARGET_SUPER_GROUP_NAME:$(GET_SUPER_GROUP_SIZE) --output $TMP_DIR/unsparse_super_empty.img"
    if [ -f "$TMP_DIR/system.img" ]; then CMD+=" --partition system:readonly:0:$TARGET_SUPER_GROUP_NAME"; fi
    eval "$CMD" || echo "Super empty skipped"
}

GENERATE_OP_LIST() {
    local OP_LIST_FILE="$TMP_DIR/dynamic_partitions_op_list"
    {
        echo "remove_all_groups"
        echo "add_group $TARGET_SUPER_GROUP_NAME $(GET_SUPER_GROUP_SIZE)"
        [ -f "$TMP_DIR/system.img" ] && echo "add system $TARGET_SUPER_GROUP_NAME" && echo "resize system $(stat -c%s "$TMP_DIR/system.img")"
    } > "$OP_LIST_FILE"
}

GENERATE_UPDATER_SCRIPT() {
    local SCRIPT_FILE="$TMP_DIR/META-INF/com/google/android/updater-script"
    {
        echo "ui_print(\"Installing One UI 7 for A04s...\");"
        echo "package_extract_file(\"boot.img\", \"$TARGET_OS_BOOT_DEVICE_PATH/boot\");"
    } > "$SCRIPT_FILE"
}

trap 'rm -rf "$TMP_DIR"' EXIT INT
[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp -a "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

LOG_STEP_IN "- Building OS partitions"
while IFS= read -r f; do
    PARTITION=$(basename "$f")
    [ "$PARTITION" == "configs" ] || [ "$PARTITION" == "kernel" ] && continue
    "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM_TYPE" -o "$TMP_DIR/$PARTITION.img" -m -S "$WORK_DIR/$PARTITION" "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION" || echo "$PARTITION failed"
done < <(find "$WORK_DIR" -maxdepth 1 -type d)
LOG_STEP_OUT

BUILD_SUPER_EMPTY
GENERATE_OP_LIST
GENERATE_UPDATER_SCRIPT

if [ -d "$WORK_DIR/kernel" ]; then cp -a "$WORK_DIR/kernel/"*.img "$TMP_DIR/"; fi

LOG "- Creating zip"
cd "$TMP_DIR" && 7z a -tzip "$OUT_DIR/$ZIP_FILE_NAME" * -mx=3
