#!/usr/bin/env bash
# UN1CA A04s One UI 7 Optimized Build Script

source "$SRC_DIR/scripts/utils/build_utils.sh" || exit 1

FORCE=false
BUILD_ROM=false
BUILD_ZIP=true

# A04s ve TUR kodlarını zorla tanımlıyoruz ki "/" hatası olmasın
SOURCE_FIRMWARE="SM-A047F/TUR"
TARGET_FIRMWARE="SM-A047F/TUR"
TARGET_CODENAME="a04s"

START_TIME="$(date +%s)"

# Dosya yollarını temizliyoruz
SOURCE_FIRMWARE_PATH="SM-A047F_TUR"
TARGET_FIRMWARE_PATH="SM-A047F_TUR"

GET_WORK_DIR_HASH() {
    find "$SRC_DIR/unica" "$SRC_DIR/target/$TARGET_CODENAME" -type f -print0 | \
        sort -z | xargs -0 sha1sum | sha1sum | cut -d " " -f 1
}

PREPARE_SCRIPT() {
    while [ "$#" != 0 ]; do
        if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then
            FORCE=true
        elif [[ "$1" == "--no-rom-zip" ]]; then
            BUILD_ZIP=false
        fi
        shift
    done
}

PRINT_BUILD_OUTCOME() {
    local EXIT_CODE="$?"
    local END_TIME="$(date +%s)"
    local ESTIMATED="$((END_TIME - START_TIME))"
    if [ "$EXIT_CODE" != "0" ]; then
        echo -e '\n\033[1;31mBuild failed\033[0m'
    else
        echo -e '\n\033[1;32mBuild completed\033[0m'
    fi
    echo "Süre: $((ESTIMATED / 60)) dk $((ESTIMATED % 60)) sn."
}

PREPARE_SCRIPT "$@"

# Build karar mekanizması
if $FORCE || [ ! -f "$WORK_DIR/.completed" ]; then
    BUILD_ROM=true
fi

trap 'PRINT_BUILD_OUTCOME' EXIT

if $BUILD_ROM; then
    [ -d "$APKTOOL_DIR" ] && rm -rf "$APKTOOL_DIR"
    
    # Firmware kontrolü ve indirme
    if [ ! -f "$ODIN_DIR/$SOURCE_FIRMWARE_PATH/.downloaded" ]; then
        LOG_STEP_IN true "Firmware indiriliyor (download_fw.sh çağrılıyor)"
        "$SRC_DIR/scripts/download_fw.sh" || exit 1
        LOG_STEP_OUT
    fi

    LOG_STEP_IN true "Firmware ayıklanıyor (extract_fw.sh)"
    "$SRC_DIR/scripts/extract_fw.sh" || exit 1
    LOG_STEP_OUT

    LOG_STEP_IN true "Çalışma dizini oluşturuluyor"
    "$SRC_DIR/scripts/internal/create_work_dir.sh" || exit 1
    LOG_STEP_OUT

    # Yamaların uygulanması
    # Not: services.jar yamanı 'unica/patches' klasörüne koyarsan otomatik uygulanır.
    [ -d "$SRC_DIR/unica/patches" ] && "$SRC_DIR/scripts/internal/apply_modules.sh" "$SRC_DIR/unica/patches"
    
    # Kendi özel blocklist temizliğini buraya ekleyebilirsin
    if [ -f "$WORK_DIR/system/etc/ldu_blocklist.xml" ]; then
        rm -f "$WORK_DIR/system/etc/ldu_blocklist.xml"
    fi

    echo -n "$(GET_WORK_DIR_HASH)" > "$WORK_DIR/.completed"
fi

# TWRP için ZIP oluşturma adımı
if $BUILD_ZIP; then
    LOG_STEP_IN true "TWRP Flashable ZIP oluşturuluyor"
    "$SRC_DIR/scripts/internal/build_flashable_zip.sh" || exit 1
    LOG_STEP_OUT
fi

exit 0
