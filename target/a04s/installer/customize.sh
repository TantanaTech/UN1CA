LOG "- Downloading your Custom Kernel (DarkOS)"
DOWNLOAD_FILE \
    "https://github.com/TantanaTech/DarkOS/releases/download/Pre/boot.tar" \
    "$TMP_DIR/boot.tar" || return 1

LOG "- Extracting boot.tar"
EVAL "cd \"$TMP_DIR\"; tar -xf \"boot.tar\"" || return 1

# DTBO kontrolü ve İşlemesi
if [ -f "$TMP_DIR/dtbo.img" ]; then
    LOG "- dtbo.img found! Processing..."
    "$SRC_DIR/scripts/unsign_bin.sh" "$TMP_DIR/dtbo.img" || return 1
    
    if ! $TARGET_DISABLE_AVB_SIGNING; then
        SIGN_IMAGE_WITH_AVB "$TMP_DIR/dtbo.img" || return 1
    fi
else
    LOG "- dtbo.img not in tar, system will use stock dtbo. No problem!"
fi

# Boot.img kontrolü ve İşlemesi
if [ -f "$TMP_DIR/boot.img" ]; then
    LOG "- boot.img found! Processing..."
    "$SRC_DIR/scripts/unsign_bin.sh" "$TMP_DIR/boot.img" || return 1
    
    if ! $TARGET_DISABLE_AVB_SIGNING; then
        SIGN_IMAGE_WITH_AVB "$TMP_DIR/boot.img" || return 1
    fi
fi
