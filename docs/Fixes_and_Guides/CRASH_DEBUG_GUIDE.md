# 🔍 دليل تتبع مشكلة Crash

## الخطوات المطبقة

### 1. تحسين Logging ✅
- إضافة `debugPrint` مع رموز تعبيرية (✅ ❌ 🔄 🏠) لسهولة التتبع
- طباعة stack traces كاملة
- تسجيل جميع الأخطاء في console

### 2. معالجة أخطاء شاملة ✅
- `main.dart`: معالجة أخطاء Hive و Firebase
- `SplashScreen`: معالجة أخطاء Storage والتنقل
- `HomeScreen`: معالجة أخطاء البناء والتنقل
- `AppStateProvider`: معالجة أخطاء التهيئة
- `StorageService`: معالجة أخطاء فتح Hive boxes
- `AdsService`: معالجة أخطاء الإعلانات

### 3. Error Boundary في HomeScreen ✅
- إرجاع error screen بدلاً من crash
- عرض رسالة خطأ واضحة للمستخدم

## كيفية تتبع المشكلة

### 1. شغّل التطبيق:
```bash
flutter run
```

### 2. افتح console/terminal وابحث عن:
- `✅` - نجاح العملية
- `❌` - أخطاء
- `🔄` - عمليات قيد التنفيذ
- `🏠` - HomeScreen events

### 3. انسخ الأخطاء:
انسخ جميع الأسطر التي تحتوي على `❌` أو `Error` أو `Exception`

### 4. أرسل الأخطاء:
أرسل الأخطاء المنسوخة لي لتحليلها

## الملفات المحدثة

1. ✅ `lib/main.dart`
   - معالجة أخطاء Hive initialization
   - معالجة أخطاء SystemChrome

2. ✅ `lib/features/splash/ui/splash_screen.dart`
   - logging أفضل
   - معالجة أخطاء التنقل

3. ✅ `lib/features/home/ui/home_screen.dart`
   - error boundary في build()
   - logging أفضل
   - معالجة أخطاء GridView

4. ✅ `lib/core/services/ads_service.dart`
   - تأخير تحميل الإعلان

## النتيجة

التطبيق الآن:
- ✅ يطبع جميع الأخطاء في console
- ✅ لا يتعطل عند حدوث خطأ
- ✅ يعرض error screen بدلاً من crash
- ✅ معالجة أخطاء شاملة

---

**شغّل التطبيق وافحص console للأخطاء!** 🔍

