# تغيير أيقونة التطبيق - MiniGenius

## الخطوات المنفذة

### 1. إنشاء الأيقونة
تم إنشاء أيقونة مخصصة للتطبيق باستخدام AI:
- شخصية دماغ كرتونية لطيفة
- قبعة تخرج
- ألوان زاهية (أزرق وأصفر)
- تصميم بسيط وودود للأطفال

### 2. إضافة الحزمة المطلوبة
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 3. إعداد التكوين
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#4A90E2"
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
```

### 4. توليد الأيقونات
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## النتيجة
✅ تم إنشاء أيقونة التطبيق بنجاح
✅ الأيقونة ستظهر على الجهاز عند تثبيت التطبيق
✅ دعم Adaptive Icons لأندرويد

## الملفات المضافة
- `assets/images/app_icon.png` - الأيقونة الأساسية
- `assets/images/app_icon_foreground.png` - أيقونة Adaptive للأندرويد

## ملاحظات
- الأيقونة ستظهر بعد إعادة build التطبيق
- لرؤية الأيقونة الجديدة، قم بإلغاء تثبيت التطبيق القديم وتثبيته مرة أخرى
- يمكنك تغيير الأيقونة بتعديل الملفات في `assets/images/` ثم تشغيل الأمر مرة أخرى
