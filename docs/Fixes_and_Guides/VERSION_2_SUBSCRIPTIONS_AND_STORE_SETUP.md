# دليـل إعداد وتفعيل اشتراكات Brainquests Pro v2.0 (App Store Connect & Google Play Console)

---

## 1. نظرة عامة على التطويرات المنفذة في الإصدار 2.0

1. **القسم المجاني 100% (Free Tier):**
   - بقاء جميع الألعاب الـ 10 الأصلية والمستويات 1-10 مجانية ومتاحة لجميع الأطفال بدون أي حظر أو إعلانات.
   - خلو التطبيق تماماً من أي شبكات إعلانية لضمان أمان الأطفال والتوافق مع قوانين COPPA وتصنيف Kids Category.

2. **القسم المدفوع (Brainquests Pro / VIP Tier):**
   - فتح المستويات المتقدمة (11 إلى 20) في جميع الألعاب الـ 10 مع عناصر وأشكال وقواعد جديدة:
     - **مطابقة الأشكال (Shape Matcher):** إضافة أشكال معقدة (المعين، الهلال، السحابة، الثماني).
     - **بطاقات الذاكرة (Memory Cards):** شبكات بطاقات عملاقة (24 إلى 32 بطاقة) وثيمات الفضاء والديناصورات.
     - **الحساب السريع (Quick Math):** معادلات مركبة من 3 حدود وجداول ضرب متقدمة حتى 12.
     - **ذاكرة الألوان (Color Memory):** 8 ألوان متزامنة مع سلاسل نغمية حتى 12 خطوة.
     - **تركيب الكلمات (Word Puzzle):** كلمات من 5 إلى 7 أحرف مع مفردات فلكية وعلمية.
     - **متاهة الكنز (Maze Runner):** متاهات عملاقة 14×14 مع مسارات بديلة.
     - **فرز العناصر (Sorting Game):** أشكال النجوم والماس وفرز مزدوج متعدد المعايير.
     - **تتابع الأنماط (Pattern Logic):** أنماط خماسية متقدمة وتناظرية.

3. **لعبة تركيب الصور (Jigsaw Puzzle):**
   - تم بناء مكتبة متكاملة من **20 مشهداً بصرياً مستقلاً** (مشهد فريد لكل مستوى من 1 إلى 20) بتقنية الرندرة الرقمية المتجهة فائقة الدقة:
     - مستويات 1-10 (مجاني): حديقة الحيوانات، سفينة الفضاء، أعماق البحار، المزرعة، السفاري، الملاهي، محطة القطار، قلعة الفرسان، البركان، عيد الميلاد.
     - مستويات 11-20 (VIP Pro): رواد القمر، السايبر سيتي، قراصنة الكنز، الشعب المرجانية، واحة المناطيد، أرض الحلوى، القطب الشمالي، الغابة المسحورة، الأبطال الخارقين، القصر الملكي الذهبي.
   - كل مشهد يتم تقطيعه ديناميكياً إلى قطع بازل حقيقية (من 4 إلى 25 قطعة) مع معاينة مرجعية للمشهد الكامل.

4. **لعبة أوجد الفروقات (Find the Difference):**
   - تم التخلص من تكرار الصورة الواحدة (`cartoon_park.png`).
   - تم إنشاء مكتبة `DifferenceLibrary` تضم **20 مشهداً فريداً لكل مستوى من 1 إلى 20** بتدرجات لونية، وعناصر مشهد متكاملة، ونقاط اختلافات مخصصة لكل موضوع (من 3 إلى 7 فروقات حسب الصعوبة).
   - مؤشرات احتفالية بدوائر خضراء وعلامات صح عند النقر، مع زر تلميح للمساعدة.

5. **الدعم الفني المباشر عبر واتساب (WhatsApp Support):**
   - تم تزويد التطبيق بزر دعم فني مباشر متصل بالرقم **`01067481561`** (`+201067481561`):
     - في شاشة الإعدادات (`SettingsScreen`) مع أيقونة واتساب خضراء.
     - في لوحة تحكم الوالدين (`ParentDashboardScreen`) في بطاقة دعم مخصصة.
   - الزر محمي بواسطة **بوابة الوالدين (Parental Gate)** بمعادلة رياضية عشوائية لضمان عدم خروج الطفل دون إذن ولي الأمر، التزاماً ببند 1.3 من إرشادات آبل.

---

## 2. إعداد الاشتراكات في App Store Connect (Apple)

### أ. إنشاء مجموعة الاشتراكات (Subscription Group)
- ادخل إلى **App Store Connect** > تطبيق **Brainquests** > **Subscriptions**.
- اضغط **Create Subscription Group**:
  - **Reference Name:** `Brainquests Pro Access`
  - **Group Display Name:** `Brainquests Pro Access`

---

### ب. باقات الاشتراك المطلوب إضافتها في المجموعة

#### 1. الاشتراك السنوي مع فترة تجربة مجانية (Annual Subscription + 7-Day Free Trial)
- **Product ID:** `minigenius_yearly`
- **Reference Name:** `Brainquests Pro Yearly`
- **Subscription Duration:** `1 Year`
- **Subscription Prices:** اختر السعر المقترح `$39.99` (أو ما يعادله بالعملات المحلية).
- **Introductory Offers (العرض التجريبي):**
  - اضغط **+ Create Introductory Offer**
  - نوع العرض: **Free Trial**
  - المدة: **7 Days**
  - الأهلية: للعملاء الجدد (New Customers).
- **Localization (العربية):**
  - **Subscription Display Name:** `اشتراك Brainquests Pro السنوي`
  - **Description:** `فتح جميع المستويات المتقدمة ورادار الذكاء المعرفي مع 7 أيام تجربة مجانية`
- **Localization (الإنجليزية):**
  - **Subscription Display Name:** `Brainquests Pro Annual`
  - **Description:** `Unlock all 20 levels, Cognitive Radar, and Pro features with 7-day free trial`

#### 2. الاشتراك الشهري (Monthly Subscription)
- **Product ID:** `minigenius_monthly`
- **Reference Name:** `Brainquests Pro Monthly`
- **Subscription Duration:** `1 Month`
- **Subscription Prices:** اختر السعر المقترح `$4.99` (أو ما يعادله بالعملات المحلية).
- **Localization (العربية):**
  - **Subscription Display Name:** `اشتراك Brainquests Pro الشهري`
  - **Description:** `وصول كامل لكافة المراحل الاحترافية ومزايا التطبيق باشتراك شهري مرن`
- **Localization (الإنجليزية):**
  - **Subscription Display Name:** `Brainquests Pro Monthly`
  - **Description:** `Monthly auto-renewing access to all Pro levels and intelligence radar`

---

### ج. باقة الشراء لمرة واحدة (Non-Consumable In-App Purchase)

#### العضوية الدائمة مدى الحياة (Lifetime Pass)
- ادخل إلى **In-App Purchases** (خارج مجموعة الاشتراكات التجديدية).
- اضغط **+** واختر **Non-Consumable**.
- **Product ID:** `minigenius_lifetime`
- **Reference Name:** `Brainquests Pro Lifetime`
- **Price:** اختر السعر المقترح `$79.99` (Tier 40 أو ما يعادله).
- **Localization (العربية):**
  - **Display Name:** `عضوية Brainquests Pro مدى الحياة`
  - **Description:** `دفعة واحدة لفتح كافة ميزات التطبيق مدى الحياة بدون اشتراكات دورية`
- **Localization (الإنجليزية):**
  - **Display Name:** `Brainquests Pro Lifetime Pass`
  - **Description:** `One-time purchase for permanent unlimited access to all Pro features`

---

### د. متطلبات مراجعة آبل الصارمة (Apple Review Guideline Checklist)

| البند في آبل | الحالة في كود Brainquests v2.0 |
| :--- | :--- |
| **زر استعادة المشتريات (Restore Purchases)** | متاح وظاهر بوضوح في أعلى شاشة الدفع وفي الأسفل ويعمل برمجياً عبر StoreKit. |
| **شروط التجديد التلقائي (Auto-Renewal Terms)** | نص إلزامي موجود أسفل الباقات يوضح التجديد قبل 24 ساعة وكيفية الإلغاء. |
| **روابط الخصوصية والاستخدام (Privacy & EULA)** | رابـطان منفصلان وظاهران: رابط سياسة الخصوصية ورابط شروط الاستخدام (Apple Standard EULA). |
| **بوابة الوالدين (Parental Gate)** | جميع نقاط الخروج (شراء الاشتراك، شاشة الترقية، الدعم عبر واتساب) محمية بمعادلة رياضية عشوائية. |
| **خلو التطبيق من الإعلانات** | 100% خالٍ من أي SDK إعلاني (تمت إزالة AdMob كلياً من المشروع). |

---

## 3. إعداد الاشتراكات في Google Play Console (Android)

### أ. الاشتراكات (Subscriptions)
- ادخل إلى **Google Play Console** > تطبيق **Brainquests** > **Monetize** > **Subscriptions**.
- أنشئ الاشتراكات التالية:

1. **الاشتراك السنوي:**
   - **Product ID:** `minigenius_yearly`
   - **Name:** `Brainquests Pro Annual`
   - **Base Plan:**
     - Type: **Auto-renewing**
     - Billing Period: **Yearly**
     - Price: `$39.99`
     - **Free Trial Offer:** مدة 7 أيام للتحميل الأول.

2. **الاشتراك الشهري:**
   - **Product ID:** `minigenius_monthly`
   - **Name:** `Brainquests Pro Monthly`
   - **Base Plan:**
     - Type: **Auto-renewing**
     - Billing Period: **Monthly**
     - Price: `$4.99`

### ب. المنتجات المدارة (In-App Products / One-Time)
- ادخل إلى **In-app products** > **Create product**:
  - **Product ID:** `minigenius_lifetime`
  - **Name:** `Brainquests Pro Lifetime`
  - **Price:** `$79.99`
  - **Status:** Active

---

## 4. ملاحظات المراجعة الخاصة بـ Apple App Store Reviewer (App Review Notes)

عند تقديم الإصدار الجديد للمراجعة، ضع هذا النص في صندوق **Review Notes** لمراجع آبل لتسريع القبول ومنع الرفض:

> **App Review Notes:**
> 
> Dear Apple App Review Team,
> 
> This update introduces **Brainquests Pro (Version 2.0)** with auto-renewable subscriptions and advanced educational content.
> 
> - **Kids Category Compliance (Guideline 1.3):** The app strictly adheres to Kids Category guidelines. There are ZERO third-party advertisements or tracking SDKs. All outbound links, including customer support and purchase flows, are safeguarded behind a rigorous Parental Gate (solving mathematical questions).
> - **Subscription Terms (Guideline 3.1.2):** The paywall clearly displays the subscription title, length of free trial (7 days), pricing, auto-renewal disclaimers, a functional "Restore Purchases" button, and direct clickable links to both our Privacy Policy and the standard Apple Terms of Use (EULA).
> - **Test Account Credentials:**
>   - Sandbox testing can be verified using any Apple Sandbox Tester account.
>   - In sandbox/test mode, the app gracefully verifies purchase receipts and unlocks Levels 11-20 and the Cognitive Development Radar instantly.
> 
> Thank you for your review!



---

## 5. الربط مع منصة التراخيص المركزية (Albalahy Licensing Hub)

تم ربط تطبيق **Brainquests v2.0** بنفس بنية السيرفر المعتمدة في `D:\projects\smartpdf\licensing_hub`:

1. **تسجيل التطبيق في قاعدة بيانات السيرفر (`licenses.db`):**
   - **App ID:** `7`
   - **App Slug:** `brainquests`
   - **App Name:** `Brainquests Pro`
   - **API Key:** `bq_live_7c8d9e0f1a2b3c4d`
   - **Status:** Active (مفعل)

2. **نقاط النهاية (API Endpoints):**
   - **فحص الترخيص:** `POST /backend/api/v1/verify.php` (مع ترويسة `X-App-Key`).
   - **تفعيل الكوبونات والاشتراكات:** `POST /backend/api/v1/redeem.php`.

3. **أكواد تجريبية جاهزة للاستخدام (Test Keys):**
   - كود ترقية دائمة مدى الحياة (Lifetime Pro): **`BRAIN-VIP-2026`**
   - كود اشتراك سنوي كامل (1 Year Pro): **`BRAIN-YEAR-2026`**

4. **واجهة التفعيل في التطبيق (Redeem In-App UI):**
   - متاحة في شاشة الإعدادات (`SettingsScreen`) وفي شاشة الترقية (`PremiumScreen`) تحت بند "تفعيل كود ترقية VIP".
   - تتيح إدخال كود الترخيص وتفعيله لحظياً عبر السيرفر وفك قفل كافة المستويات الاحترافية (11-20) ورادار الذكاء المعرفي.
