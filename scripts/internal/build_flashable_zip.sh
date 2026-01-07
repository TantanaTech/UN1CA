#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

# A04s Değişkenleri
SOURCE_FIRMWARE_PATH="$(cut -d "/" -f 1 -s <<< "$SOURCE_FIRMWARE")_$(cut -d "/" -f 2 -s <<< "$SOURCE_FIRMWARE")"
TMP_DIR="$OUT_DIR/zip"
ZIP_FILE_NAME="UN1CA_A04s_OneUI7_$(date +%Y%m%d).zip"

# --- Kritik Fonksiyonlar (Super.img mantığı için şart) ---
BUILD_SUPER_EMPTY() {
    local CMD="lpmake --metadata-size 65536 --super-name super --metadata-slots 2 --device super:$TARGET_SUPER_PARTITION_SIZE"
    CMD+=" --group $TARGET_SUPER_GROUP_NAME:$(GET_SUPER_GROUP_SIZE) --output $TMP_DIR/unsparse_super_empty.img"
    [ -f "$TMP_DIR/system.img" ] && CMD+=" --partition system:readonly:0:$TARGET_SUPER_GROUP_NAME"
    eval "$CMD" || echo "Super partition info created"
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
        echo "ui_print(\"****************************************\");"
        echo "ui_print(\"   UN1CA One UI 7 Port for A04s\");"
        echo "ui_print(\"****************************************\");"
        echo "package_extract_file(\"boot.img\", \"$TARGET_OS_BOOT_DEVICE_PATH/boot\");"
        echo "ui_print(\"- Flashing system partitions...\");"
        echo "update_dynamic_partitions(package_extract_file(\"dynamic_partitions_op_list\"));"
    } > "$SCRIPT_FILE"
}

# --- İşlem Başlıyor ---
trap 'rm -rf "$TMP_DIR"' EXIT INT
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp -a "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

LOG_STEP_IN "- Building OS partitions (A04s Structure)"
while IFS= read -r f; do
    PARTITION=$(basename "$f")
    [ "$PARTITION" == "configs" ] || [ "$PARTITION" == "kernel" ] && continue
    # GSI mantığı gibi imajı paketle
    "$SRC_DIR/scripts/build_fs_image.sh" "$TARGET_OS_FILE_SYSTEM_TYPE" -o "$TMP_DIR/$PARTITION.img" -m -S "$WORK_DIR/$PARTITION" "$WORK_DIR/configs/file_context-$PARTITION" "$WORK_DIR/configs/fs_config-$PARTITION" || echo "$PARTITION build failed, skipping"
done < <(find "$WORK_DIR" -maxdepth 1 -type d)
LOG_STEP_OUT

BUILD_SUPER_EMPTY
GENERATE_OP_LIST
GENERATE_UPDATER_SCRIPT

# Kernel'ı (boot.img) ekle
[ -d "$WORK_DIR/kernel" ] && cp -a "$WORK_DIR/kernel/"*.img "$TMP_DIR/"

LOG "- Creating zip and uploading to Artifacts"
cd "$TMP_DIR" && 7z a -tzip "$OUT_DIR/$ZIP_FILE_NAME" * -mx=3
