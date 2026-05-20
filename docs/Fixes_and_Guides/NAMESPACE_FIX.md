# إصلاح مشكلة Namespace لـ google_mobile_ads

## المشكلة
```
Namespace not specified. Specify a namespace in the module's build file: 
C:\Users\...\google_mobile_ads-3.1.0\android\build.gradle
```

## الحل المطبق
تم تحديث `google_mobile_ads` من `^3.1.0` إلى `^5.1.0` في `pubspec.yaml`

الإصدار الجديد (5.3.1) يدعم namespace تلقائياً ولا يحتاج إلى إعدادات إضافية.

## الخطوات المتبعة
1. ✅ تحديث pubspec.yaml
2. ✅ تشغيل `flutter clean`
3. ✅ تشغيل `flutter pub get`

## الخطوة التالية
```bash
flutter run
```

إذا استمرت المشكلة، يمكن تجربة:
1. حذف `.dart_tool` و `build` folders
2. تشغيل `flutter pub cache repair`
3. إعادة تشغيل `flutter pub get`

