# تعليمات تحميل ملف Firebase Configuration

## ⚠️ مهم جداً

ملف `google-services.json` **محظور** بواسطة `.gitignore` لأسباب أمنية (وهذا صحيح).
يجب عليك تحميله يدوياً من Firebase Console.

---

## خطوات التحميل

### 1. افتح Firebase Console
اذهب إلى: https://console.firebase.google.com/

### 2. اختر المشروع
- اختر مشروع **MiniGenius**
- Project ID: `minigenius-6f5c6`
- Project Number: `826537183870`

### 3. اذهب إلى إعدادات المشروع
1. اضغط على أيقونة ⚙️ (Settings) بجانب "Project Overview"
2. اختر **Project settings**

### 4. اختر تطبيق Android
1. في قسم "Your apps"
2. ابحث عن التطبيق بـ Package name: `com.minigenius.app`
3. App ID: `1:826537183870:android:75043d8fcdd03de98e262f`

### 5. حمّل الملف
1. اضغط على زر **"Download google-services.json"**
2. سيتم تحميل ملف باسم `google-services.json`

### 6. ضع الملف في المكان الصحيح
انسخ الملف إلى:
```
c:\projects\Brainquests\android\app\google-services.json
```

**المسار الكامل:**
```
Brainquests/
  └── android/
      └── app/
          └── google-services.json  ← ضع الملف هنا
```

---

## التحقق من التثبيت الصحيح

بعد وضع الملف، تحقق من:

### 1. الملف في المكان الصحيح
```powershell
# في PowerShell
Test-Path "c:\projects\Brainquests\android\app\google-services.json"
# يجب أن يعرض: True
```

### 2. محتوى الملف صحيح
افتح الملف وتحقق من:
- `"project_number": "826537183870"`
- `"package_name": "com.minigenius.app"`
- `"mobilesdk_app_id": "1:826537183870:android:75043d8fcdd03de98e262f"`

### 3. اختبار البناء
```bash
flutter clean
flutter pub get
flutter run
```

إذا لم تظهر أخطاء Firebase، فالتثبيت صحيح! ✅

---

## استكشاف الأخطاء

### خطأ: "Failed to load FirebaseOptions"
**السبب:** الملف غير موجود أو في مكان خاطئ
**الحل:** تأكد من المسار الصحيح: `android/app/google-services.json`

### خطأ: "Default FirebaseApp is not initialized"
**السبب:** الملف موجود لكن محتواه غير صحيح
**الحل:** حمّل الملف مرة أخرى من Firebase Console

### خطأ: Package name mismatch
**السبب:** الملف لتطبيق آخر
**الحل:** تأكد من تحميل الملف للتطبيق الصحيح (`com.minigenius.app`)

---

## ملاحظات مهمة

- ✅ **لا تشارك** هذا الملف على GitHub (محظور تلقائياً)
- ✅ **احتفظ بنسخة احتياطية** في مكان آمن
- ✅ **لا تعدّل** محتوى الملف يدوياً
- ✅ إذا غيّرت Package name، حمّل الملف مرة أخرى

---

## بعد التثبيت

بعد وضع الملف بنجاح، سيعمل:
- ✅ Firebase Analytics (تتبع الأحداث)
- ✅ Firebase Crashlytics (تقارير الأخطاء)
- ✅ Firebase Performance (مراقبة الأداء)

يمكنك متابعة البيانات من Firebase Console! 🎉
