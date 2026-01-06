#!/usr/bin/env bash
# hello :)
# UN1CA PM Blocklist patch - A04s Fixed Version
# Bu script, dosya eksikliğinde build'in çökmesini engeller.

# 1. Dosya Silme İşlemi (Güvenli Kontrol)
# A04s firmware yapısında ldu_blocklist.xml veya unica_blocklist.xml olabilir.
if [ -f "$WORK_DIR/system/etc/ldu_blocklist.xml" ]; then
    echo "-> ldu_blocklist.xml bulundu, siliniyor..."
    DELETE_FROM_WORK_DIR "system" "system/etc/ldu_blocklist.xml"
elif [ -f "$WORK_DIR/system/etc/unica_blocklist.xml" ]; then
    echo "-> unica_blocklist.xml bulundu, siliniyor..."
    DELETE_FROM_WORK_DIR "system" "system/etc/unica_blocklist.xml"
else
    echo "!! UYARI: Herhangi bir blocklist dosyası bulunamadı, atlanıyor."
fi

# 2. services.jar Yaması
# services.jar sistemin kalbidir, ancak yama dosyası eksikse hata vermemesi için kontrol ekliyoruz.
if [ -f "$WORK_DIR/system/framework/services.jar" ]; then
    echo "-> services.jar yamalanıyor..."
    
    # Ana yama (0001-Allow-custom-PackageBlockListPolicy.patch)
    if [ -d "$MODPATH/services.jar" ]; then
        APPLY_PATCH "system" "system/framework/services.jar" \
            "$MODPATH/services.jar/0001-Allow-custom-PackageBlockListPolicy.patch" || echo "Yama atlandı"
    fi

    # Smali yaması
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/samsung/android/server/pm/install/PackageBlockListPolicy\$1.smali" 'remove' || echo "Smali yaması atlandı"
else
    echo "!! KRİTİK UYARI: services.jar bulunamadı! Bu adım tamamen atlanıyor."
fi

exit 0
