# ✅ إصلاح مشكلة AdMob App ID

## المشكلة
```
Missing application ID. AdMob publishers should follow the instructions here:
https://googlemobileadssdk.page.link/admob-android-update-manifest
to add a valid App ID inside the AndroidManifest.
```

## السبب
AdMob يتطلب App ID في AndroidManifest.xml حتى لو لم نستخدم الإعلانات.

## الحل المطبق

### إضافة AdMob App ID في AndroidManifest.xml
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**ملاحظة:** هذا App ID للاختبار. في الإنتاج، يجب استبداله بـ App ID الحقيقي من AdMob Console.

## كيفية الحصول على App ID الحقيقي

1. افتح [AdMob Console](https://admob.google.com/)
2. اذهب إلى Apps → App settings
3. انسخ App ID (شكل: `ca-app-pub-XXXXXXXXXX~XXXXXXXXXX`)
4. استبدل القيمة في AndroidManifest.xml

## الملفات المحدثة

1. ✅ `android/app/src/main/AndroidManifest.xml`
   - إضافة AdMob App ID meta-data

---

**التطبيق يجب أن يعمل الآن!** 🎉

