# إصلاح مشكلة AdMob/Firebase Manifest Conflict

## المشكلة
تعارض بين:
- `play-services-ads-lite:23.6.0` (من google_mobile_ads)
- `play-services-measurement-api:21.6.1` (من firebase_analytics)

كلاهما يحاول تعريف `android.adservices.AD_SERVICES_CONFIG` بقيم مختلفة.

## الحل المطبق

### 1. إضافة resolution strategy في build.gradle.kts
```kotlin
configurations.all {
    resolutionStrategy {
        force("com.google.android.gms:play-services-measurement-api:21.6.1")
    }
}
```

### 2. إنشاء ملف XML المطلوب
تم إنشاء `android/app/src/main/res/xml/gma_ad_services_config.xml`

### 3. إضافة property element في AndroidManifest.xml
```xml
<property
    android:name="android.adservices.AD_SERVICES_CONFIG"
    android:resource="@xml/gma_ad_services_config"
    tools:replace="android:resource" />
```

### 4. إضافة tools namespace
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
```

## الملفات المحدثة
- ✅ `android/build.gradle.kts` - إضافة resolution strategy
- ✅ `android/app/src/main/res/xml/gma_ad_services_config.xml` - ملف جديد
- ✅ `android/app/src/main/AndroidManifest.xml` - إضافة property element

## النتيجة
يجب أن يعمل التطبيق الآن بدون تعارضات! 🎉

