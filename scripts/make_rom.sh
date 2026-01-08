#!/usr/bin/env bash
source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

FORCE=false
BUILD_ROM=false
BUILD_ZIP=true

# Burayı elle sabitliyoruz ki "_" hatası oluşmasın
SOURCE_FIRMWARE_PATH="SM-A047F_TUR"
TARGET_FIRMWARE_PATH="SM-A047F_TUR"
TARGET_CODENAME="a04s"

START_TIME="$(date +%s)"

PREPARE_SCRIPT() {
    while [ "$#" != 0 ]; do
        if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then FORCE=true; fi
        shift
    done
}

PREPARE_SCRIPT "$@"
trap 'echo "Bitti."' EXIT

if $FORCE || [ ! -f "$WORK_DIR/.completed" ]; then
    BUILD_ROM=true
fi

if $BUILD_ROM; then
    # Firmware kontrolü
    if [ ! -f "$ODIN_DIR/$SOURCE_FIRMWARE_PATH/.downloaded" ]; then
        "$SRC_DIR/scripts/download_fw.sh" || exit 1
    fi

    # Ayıklama adımına geçiş
    LOG_STEP_IN true "Firmware ayıklanıyor"
    "$SRC_DIR/scripts/extract_fw.sh" || exit 1
    LOG_STEP_OUT

    LOG_STEP_IN true "Çalışma dizini hazırlanıyor"
    "$SRC_DIR/scripts/internal/create_work_dir.sh" || exit 1
    LOG_STEP_OUT

    # Yamalar (unica/patches klasöründeki dosyalar uygulanır)
    [ -d "$SRC_DIR/unica/patches" ] && "$SRC_DIR/scripts/internal/apply_modules.sh" "$SRC_DIR/unica/patches"
    
    echo -n "done" > "$WORK_DIR/.completed"
fi

if $BUILD_ZIP; then
    LOG_STEP_IN true "TWRP ZIP Oluşturuluyor"
    "$SRC_DIR/scripts/internal/build_flashable_zip.sh" || exit 1
    LOG_STEP_OUT
fi
