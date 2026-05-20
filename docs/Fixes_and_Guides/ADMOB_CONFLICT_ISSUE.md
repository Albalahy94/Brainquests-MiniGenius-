# مشكلة AdMob Manifest Conflict

## المشكلة
عند تفعيل `google_mobile_ads`، يحدث تعارض في AndroidManifest بين:
- `play-services-ads-lite:23.6.0`
- `play-services-measurement-api:21.6.1`

الخطأ:
```
Attribute property#android.adservices.AD_SERVICES_CONFIG@resource value=(@xml/gma_ad_services_config)
is also present at value=(@xml/ga_ad_services_config)
```

## المحاولات التي فشلت
1. ✗ إضافة `tools:replace="android:resource"` في main manifest
2. ✗ إضافة configurations في build.gradle.kts
3. ✗ إنشاء debug manifest يدوي

## الحل المؤقت
تم تعطيل AdMob مؤقتاً حتى يتم حل المشكلة.

## الحلول المقترحة

### الحل 1: انتظار تحديث المكتبات
- انتظر تحديث `google_mobile_ads` لحل التعارض
- تابع: https://github.com/googleads/googleads-mobile-flutter/issues

### الحل 2: استخدام إصدار أقدم
```yaml
google_mobile_ads: ^4.0.0  # إصدار أقدم قد يعمل
```

### الحل 3: Gradle resolution strategy
في `android/build.gradle.kts`:
```kotlin
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.google.android.gms") {
            if (requested.name == "play-services-measurement-api") {
                useVersion("21.6.1")
            }
        }
    }
}
```

### الحل 4: استخدام AdMob بدون Firebase Analytics
إزالة `firebase_analytics` من pubspec.yaml (لكن سنخسر Analytics)

## التوصية
**انتظر تحديث المكتبات** - هذه مشكلة معروفة وسيتم حلها قريباً.

في الوقت الحالي، التطبيق يعمل بدون إعلانات.
