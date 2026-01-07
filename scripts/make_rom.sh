#!/usr/bin/env bash
# UN1CA A04s One UI 7 Build Script

# 1. Ön Hazırlık ve Yamalar
echo "[A04s Port]: Yama işlemleri başlatılıyor..."

# [span_2](start_span)Blocklist kontrolü ve temizliği[span_2](end_span)
if [ -f "$WORK_DIR/system/etc/ldu_blocklist.xml" ]; then
    echo "-> ldu_blocklist.xml bulundu, siliniyor..."
    DELETE_FROM_WORK_DIR "system" "system/etc/ldu_blocklist.xml"
elif [ -f "$WORK_DIR/system/etc/unica_blocklist.xml" ]; then
    echo "-> unica_blocklist.xml bulundu, siliniyor..."
    DELETE_FROM_WORK_DIR "system" "system/etc/unica_blocklist.xml"
else
    [span_3](start_span)echo "!! UYARI: Herhangi bir blocklist dosyası bulunamadı, atlanıyor."[span_3](end_span)
fi

# [span_4](start_span)services.jar kontrolü ve yamalanması[span_4](end_span)
if [ -f "$WORK_DIR/system/framework/services.jar" ]; then
    echo "-> services.jar yamalanıyor..."
    if [ -d "$MODPATH/services.jar" ]; then
        APPLY_PATCH "system" "system/framework/services.jar" \
            "$MODPATH/services.jar/0001-Allow-custom-PackageBlockListPolicy.patch" || echo "Yama atlandı"
    fi
    SMALI_PATCH "system" "system/framework/services.jar" \
        "smali_classes2/com/samsung/android/server/pm/install/PackageBlockListPolicy\$1.smali" 'remove' || echo "Smali yaması atlandı"
else
    [span_5](start_span)echo "!! KRİTİK UYARI: services.jar bulunamadı!"[span_5](end_span)
fi

# 2. KRİTİK ADIM: Build Sürecini Devam Ettir
# Scriptin burada durmaması (exit 0 yapmaması) gerekir. 
# UN1CA'nın ana build fonksiyonlarını çağırmalıyız.

echo "[A04s Port]: Paketleme (Image Generation) başlıyor..."

# UN1CA standart build fonksiyonlarını tetikleyin
# Eğer scriptin sonunda exit 0 dersen alt fonksiyonlar çalışmaz.
# Bu script genellikle UN1CA'nın ana motoru tarafından "source" edilir.
# Eğer --no-rom-zip kullanıyorsan sadece imajlar oluşur.

# Sadece imajları oluşturmak için gereken komutları buraya ekliyoruz:
# Not: UN1CA'nın ana döngüsü bu script bittikten sonra devam etmelidir.
