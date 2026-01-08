#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

# A04s İçin Sabit Değerler (Hata almamak için)
TARGET_SUPER_PARTITION_SIZE=9126805504 # Yaklaşık 8.5GB
TARGET_SUPER_GROUP_NAME="qti_dynamic_partitions"
TARGET_SUPER_GROUP_SIZE=9122611200
TMP_DIR="$OUT_DIR/zip"
ZIP_FILE_NAME="UN1CA_A04s_OneUI7_$(date +%Y%m%d).zip"

# Fonksiyon hatasını önlemek için manuel tanımlama
GET_SUPER_GROUP_SIZE() {
    echo "$TARGET_SUPER_GROUP_SIZE"
}

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
        if [ -f "$TMP_DIR/system.img" ]; then
            local SIZE=$(stat -c%s "$TMP_DIR/system.img")
            echo "add system $TARGET_SUPER_GROUP_NAME"
            echo "resize system $SIZE"
        fi
    } > "$OP_LIST_FILE"
}

GENERATE_UPDATER_SCRIPT() {
    local SCRIPT_FILE="$TMP_DIR/META-INF/com/google/android/updater-script"
    {
        echo "ui_print(\"****************************************\");"
        echo "ui_print(\"   UN1CA One UI 7 Port for A04s\");"
        echo "ui_print(\"****************************************\");"
        echo "ui_print(\"- Flashing Boot Image...\");"
        echo "package_extract_file(\"boot.img\", \"/dev/block/by-name/boot\");"
        echo "ui_print(\"- Flashing system partitions...\");"
        echo "update_dynamic_partitions(package_extract_file(\"dynamic_partitions_op_list\"));"
    } > "$SCRIPT_FILE"
}

# --- İşlem Başlıyor ---
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/META-INF/com/google/android"
cp -a "$SRC_DIR/prebuilts/bootable/deprecated-ota/updater" "$TMP_DIR/META-INF/com/google/android/update-binary"

LOG_STEP_IN "- Building OS partitions (A04s Structure)"
# Imajları WORK_DIR içinden doğrudan paketle
for part in "system" "vendor" "product"; do
    if [ -d "$WORK_DIR/$part" ]; then
        "$SRC_DIR/scripts/build_fs_image.sh" "erofs" -o "$TMP_DIR/$part.img" -m -S "$WORK_DIR/$part" || echo "$part build failed"
    fi
done
LOG_STEP_OUT

BUILD_SUPER_EMPTY
GENERATE_OP_LIST
GENERATE_UPDATER_SCRIPT

# Ana imajları ekle (boot ve vbmeta)
cp "$WORK_DIR/"*.img "$TMP_DIR/" 2>/dev/null || true

LOG "- Creating zip and uploading to Artifacts"
cd "$TMP_DIR" && 7z a -tzip "$OUT_DIR/$ZIP_FILE_NAME" * -mx=3
