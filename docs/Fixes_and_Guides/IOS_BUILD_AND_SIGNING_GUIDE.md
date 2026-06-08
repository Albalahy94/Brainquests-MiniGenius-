# 🍏 دليل توثيق وحل مشاكل بناء وإعداد نسخة iOS (Apple)

يوضح هذا الدليل المشاكل التقنية التي واجهتنا أثناء إعداد وبناء نسخة iOS لتطبيق **MiniGenius (Brainquests)**، والحلول التي تم تطبيقها لضمان عدم تكرار هذه المشاكل مستقبلاً أثناء التطوير أو البناء الآلي (CI/CD).

---

## 1. مشكلة Firebase و CocoaPods (Non-modular Headers)
### 🔍 المشكلة:
عند بناء التطبيق باستخدام Firebase SDK، يفشل Xcode في التجميع (Compile) مع ظهور خطأ مثل:
`Double-quoted include "..." in framework header, expected angle-bracketed instead` أو خطأ متعلق بـ `non-modular header inside framework module`.

### 🛠️ الحل الجذري:
تم حل المشكلة من خلال اتخاذ خطوتين في ملف التكوين:
1. **استخدام الربط الساكن (Static Linkage)** في ملف `ios/Podfile`:
   ```ruby
   use_frameworks! :linkage => :static
   ```
2. **سماح تضمين الـ Non-modular Headers** لجميع الأهداف (Targets) داخل الـ Podfile:
   تم إضافة الكود التالي داخل كتل الإعداد (Post-install block):
   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)
       target.build_configurations.each do |config|
         config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
       end
     end
   end
   ```

---

## 2. تخصيص ملف الـ Podfile (تضارب WebView)
### 🔍 المشكلة:
حدوث مشاكل وتضاربات في CocoaPods Specs لـ `webview_flutter` عند استخدام معالجة Pods الافتراضية لـ Flutter.

### 🛠️ الحل الجذري:
تم استبدال نظام المساعدة التلقائي لـ Flutter في الـ Podfile بنظام بناء مخصص ومستقر يتيح لـ Xcode و CocoaPods إدارة التبعيات بشكل مباشر وسلس دون تداخل.

---

## 3. انهيار التطبيق عند التشغيل بسبب AdMob (iOS App ID)
### 🔍 المشكلة:
ينهار التطبيق فوراً عند تشغيله على محاكي أو جهاز iOS حقيقي مع ظهور خطأ يفيد بعدم تهيئة AdMob بشكل صحيح.

### 🛠️ الحل الجذري:
تتطلب مكتبة Google Mobile Ads وجود معرف التطبيق (App ID) في ملف الخصائص لتجنب الانهيار. تم إضافة المفتاح التالي في ملف `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2410231577080071~2357323766</string>
```

---

## 4. تعليق مراجعة التطبيق في TestFlight (تصدير التشفير)
### 🔍 المشكلة:
عند رفع نسخة جديدة إلى TestFlight، يظل البناء معلقاً بانتظار إجابة يدوية عن أسئلة امتثال التصدير (Export Compliance) بسبب وجود استخدام للتشفير (حتى وإن كان افتراضياً من نظام التشغيل أو الاتصال بـ HTTPS).

### 🛠️ الحل الجذري:
لتخطي هذا التأكيد اليدوي وتفعيل المعالجة التلقائية، تم إضافة المفتاح التالي في ملف `ios/Runner/Info.plist`:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## 5. مشاكل التوقيع اليدوي والتلقائي في Xcode (Manual Signing)
### 🔍 المشكلة:
عند محاولة بناء التطبيق كـ Archive أو عبر سطر الأوامر (CI/CD)، يفشل البناء بسبب خطأ:
`Code Signing Error: Signing for "Runner" requires a development team` أو عدم تطابق ملف التعريف (Provisioning Profile) مع حساب المطور.

### 🛠️ الحل الجذري:
تم كتابة سكربت يقوم بحقن وتحديث ملف `project.pbxproj` بشكل ديناميكي لتهيئة التوقيع اليدوي، وذلك بالقيام بالتالي:
1. إعداد `CODE_SIGN_STYLE = Manual` لتعطيل التوقيع التلقائي الذي قد يسبب تعارضات على الـ Runner.
2. حقن معرف الفريق (`DEVELOPMENT_TEAM`).
3. ربط ملف التعريف بدقة باستخدام `PROVISIONING_PROFILE` (معرف الـ UUID لملف التعريف) و `PROVISIONING_PROFILE_SPECIFIER` (اسم ملف التعريف).

---

## 6. مشاكل الترجمة المفقودة (Localizations Errors)
### 🔍 المشكلة:
عند تعديل ملفات الترجمة `.arb` أو تشغيل كود نظيف، قد يفشل البناء الثابت (Flutter Analyze) أو البناء العادي بسبب عدم وجود المتغيرات الجديدة في فئة `AppLocalizations` المولدة.

### 🛠️ الحل الجذري:
يجب دائماً تشغيل التوليد التلقائي لملفات الترجمة قبل عملية البناء عن طريق الأمر:
```bash
flutter gen-l10n
```
تم دمج هذا الأمر كخطوة أساسية في خط البناء التلقائي (GitHub Actions Workflow) لضمان عدم توقف البناء بسبب أي نصوص ترجمة جديدة.
