#!/usr/bin/env bash

# UN1CA floating_feature patch script (A04s Fixed Version)
# Bu script, dosya bulunamadığında build'in çökmesini engeller.

DEPRECATED="
SEC_FLOATING_FEATURE_AUDIO_CONFIG_FMRADIO_EXTERNAL_DEVICE
SEC_FLOATING_FEATURE_AUDIO_CONFIG_VOLUMEMONITOR_PHASE
SEC_FLOATING_FEATURE_BATTERY_SUPPORT_WIRELESS_TX_5V_TA
SEC_FLOATING_FEATURE_BIXBY_SUPPORT_USERKWD_WAKEUP
SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE
SEC_FLOATING_FEATURE_COMMON_CONFIG_DUAL_IMS
SEC_FLOATING_FEATURE_COMMON_SUPPORT_CONVENTIONAL_MODE
SEC_FLOATING_FEATURE_COMMON_SUPPORT_D2D_NUMBER_TRANSFER_SEND_ONLY
SEC_FLOATING_FEATURE_COMMON_SUPPORT_DEX_ON_PC
SEC_FLOATING_FEATURE_COMMON_SUPPORT_EMBEDDED_SIM
SEC_FLOATING_FEATURE_COMMON_SUPPORT_EPDG_CROSS_SIM
SEC_FLOATING_FEATURE_COMMON_SUPPORT_KNOX_DESKTOP
SEC_FLOATING_FEATURE_COMMON_SUPPORT_SAFETYCARE
SEC_FLOATING_FEATURE_COMMON_SUPPORT_SPEN_ALERT
SEC_FLOATING_FEATURE_FMRADIO_CONFIG_COMMON_SUPPORT_HYBRIDSEARCH
SEC_FLOATING_FEATURE_FMRADIO_REMOVE_AF_MENU
"

BLACKLIST="
SEC_FLOATING_FEATURE_AUDIO_CONFIG_ASSISTANT_SPEAKER_MAX_VOLUME
SEC_FLOATING_FEATURE_CAMERA_CONFIG_AI_DEFLICKER
SEC_FLOATING_FEATURE_COMMON_CONFIG_AI_VERSION
SEC_FLOATING_FEATURE_COMMON_SUPPORT_DESKTOP_WINDOWING
SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE
"

FALLBACK="
SEC_FLOATING_FEATURE_AUDIO_CONFIG_INTERPRETER=0
SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN=0
"

APPLY_TARGET_FEATURE()
{
    local TARGET_FIRMWARE_PATH="SM-A047F_TUR"
    local SOURCE_FILE="$WORK_DIR/system/etc/floating_feature.xml"
    local TARGET_FILE="$FW_DIR/$TARGET_FIRMWARE_PATH/system/etc/floating_feature.xml"

    # DOSYA KONTROLÜ: Eğer dosya yoksa build'i bozma, log bırak ve çık.
    if [ ! -f "$TARGET_FILE" ]; then
        echo "!! UYARI: $TARGET_FILE bulunamadı. Manuel enjeksiyon gerekecek!"
        return 0
    fi

    if [ ! -f "$SOURCE_FILE" ]; then
        echo "!! UYARI: $SOURCE_FILE bulunamadı. Work_dir hatası!"
        return 0
    fi

    local FEATURE
    local SOURCE_VALUE
    local TARGET_VALUE

    # Step 1: work_dir içindeki dosyayı hedef firmware değerleriyle güncelle
    while IFS= read -r l; do
        if [ ! "$l" ] || [[ "$l" == *"xml"* ]] || [[ "$l" == *"SecFloatingFeatureSet"* ]]; then
            continue
        fi

        FEATURE="$(awk -F '<|>' '{print $2}' <<< "$l")"

        if grep -q -w "$FEATURE" <<< "$BLACKLIST"; then
            continue
        fi

        SOURCE_VALUE="$(GET_FLOATING_FEATURE_CONFIG "$SOURCE_FILE" "$FEATURE")"
        TARGET_VALUE="$(GET_FLOATING_FEATURE_CONFIG "$TARGET_FILE" "$FEATURE")"

        if [ ! "$TARGET_VALUE" ]; then
            TARGET_VALUE="$(cut -d "=" -f 2- < <(grep -w "$FEATURE" <<< "$FALLBACK"))"
        fi

        if [ ! "$TARGET_VALUE" ]; then
            SET_FLOATING_FEATURE_CONFIG "$FEATURE" --delete
        elif [[ "$SOURCE_VALUE" != "$TARGET_VALUE" ]]; then
            SET_FLOATING_FEATURE_CONFIG "$FEATURE" "$TARGET_VALUE"
        fi
    done < "$SOURCE_FILE"
}

APPLY_CUSTOM_FEATURE()
{
    [ ! -f "$1" ] && return 0
    while IFS= read -r l; do
        [[ "$l" == "#"* ]] || [ ! "$l" ] && continue
        if [[ "$l" == "SEC_FLOATING_FEATURE_"*"="* ]]; then
            SET_FLOATING_FEATURE_CONFIG "$(cut -d "=" -f 1 <<< "$l")" "$(cut -d "=" -f 2- <<< "$l")"
        fi
    done < "$1"
}

# İşlemleri Başlat
LOG_STEP_IN "- Applying target floating feature config"
APPLY_TARGET_FEATURE || echo "Target feature skip"
LOG_STEP_OUT

# Platform ve Cihaz özel ayarları (varsa)
[ -f "$SRC_DIR/platform/$TARGET_PLATFORM/sff.sh" ] && APPLY_CUSTOM_FEATURE "$SRC_DIR/platform/$TARGET_PLATFORM/sff.sh"
[ -f "$SRC_DIR/target/$TARGET_CODENAME/sff.sh" ] && APPLY_CUSTOM_FEATURE "$SRC_DIR/target/$TARGET_CODENAME/sff.sh"

unset DEPRECATED BLACKLIST FALLBACK
