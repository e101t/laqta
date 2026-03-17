# Laqta Product Spec + UI Auto Design (Phase 1)

## ملخص المنتج (10 أسطر)
1) المشكلة: سوق التصوير غير منظم، والمستخدم لا يعرف من يثق به ولا كيف يقارن الأسعار والجودة.
2) الحل: منصة موحدة تجمع الاكتشاف والحجز والدفع والدردشة وإدارة الأعمال.
3) قيمة للزبون: اختيار سريع، حجز آمن، متابعة واضحة لتقدم الجلسة.
4) قيمة للمصور: تدفق عملاء مستمر، إدارة جدول، وسمعة قابلة للقياس.
5) شبكة اجتماعية تزيد التفاعل اليومي وتخلق اكتشافاً عضوياً.
6) تسعير شفاف مع ملفات مصورين قابلة للمقارنة.
7) سياسات إلغاء وإشعارات لحظية تقلل النزاعات.
8) قابلية توسع جغرافي بسرعة عبر المحافظات.
9) نموذج ربحي واضح: عمولة + مزايا مدفوعة للمصورين.
10) نجاح تجاري متوقع بسبب دمج الخدمات الأساسية في تجربة واحدة.

## الأدوار والهوية
- المستخدم: زبون/مصور مع إمكانية امتلاك الدورين في حساب واحد.
- Username فريد (حروف أو حروف+أرقام) مع تحقق لحظي ونسخة lowercase للحجز.
- الجنس: ذكر/أنثى مع خيار إخفاء العرض العام.
- تحقق عمر +18 إلزامي قبل إكمال الملف.
- المحافظة إلزامية لضبط البحث والتوصية.

## User Journey كامل (بالحالات)
1) فتح التطبيق → Splash: تهيئة الخدمات.
   - فشل التهيئة: شاشة خطأ + زر إعادة المحاولة.
2) اختيار اللغة → تبديل RTL/LTR فوري وحفظ التفضيل.
3) Onboarding → شرائح القيمة.
   - تخطي: انتقال مباشر لصفحة الدخول.
4) تسجيل/دخول → Phone OTP + Google + Apple.
   - فشل الشبكة: رسالة + Retry.
5) OTP → إدخال رمز التحقق.
   - OTP خاطئ: تنبيه واضح + إعادة إدخال.
   - انتهاء الوقت: زر إعادة إرسال بعد مؤقت.
6) اختيار الدور → زبون/مصور/كلاهما.
7) بناء الهوية الأساسية → Username + الاسم + الجنس + المحافظة + سنة الميلاد.
   - Username غير متاح: رسالة فورية وتعطيل المتابعة.
   - ملف غير مكتمل: منع الانتقال + توجيه واضح.
8) إعداد الملف → زبون أو مصور.
9) Home → قصص + Feed + Discover.
10) متابعة مصور → تحديث فوري للحالة.
11) منشورات/ستوري → تفاعل وإعجاب.
12) بحث + فلاتر → نتائج فورية.
   - لا نتائج: Empty مع اقتراحات.
13) ملف مصور → تبويبات + متابعة/مراسلة/حجز.
14) حجز → تاريخ/وقت/نوع/موقع + ملخص.
   - تعارض موعد: اقتراح مواعيد بديلة.
15) دفع → Stripe.
   - دفع فاشل: رسالة واضحة + إعادة المحاولة.
16) دردشة → رسائل فورية + مرفقات.
17) تنفيذ جلسة → تأكيد الإنجاز.
18) تقييم → نجوم + تعليق.
19) إشعارات → تحديثات مستمرة.
20) إعدادات/بلاغ → إدارة الخصوصية والدعم.
   - إلغاء حجز: عرض سياسة ورسوم قبل التأكيد.

## تصميم الشاشات بالتفصيل (Screen-by-Screen)

### A) Splash + اختيار اللغة + Onboarding
- الهدف: تعريف الهوية وإعداد اللغة.
- Widgets: Scaffold, Stack, PageView, SafeArea, FilledButton.
- عناصر UI: شعار + صورة Hero + مؤشرات صفحات + اختيار لغة.
- الحالات: Loading/Retry/Error.
- النصوص: "اختر اللغة"، "التالي"، "تخطي".
- التنقل: GoRouter إلى Auth.
- Micro-interactions: Fade + Slide + Haptic عند اختيار اللغة.

### B) Login/Signup + OTP
- الهدف: مصادقة سريعة وآمنة.
- Widgets: Scaffold, AppBar, TextField, PinInput, BottomSheet.
- عناصر UI: أزرار Google/Apple، إدخال رقم، إدخال OTP.
- الحالات: Loading/OTP خطأ/OTP منتهي.
- النصوص: "تسجيل الدخول"، "أدخل رمز التحقق".
- التنقل: GoRouter إلى Role.
- Micro-interactions: Shake عند خطأ OTP، Haptic عند النجاح.

### C) Role Selection + Basic Identity
- الهدف: تحديد الدور وبناء الهوية.
- Widgets: Scaffold, Card, Form, Dropdown, Checkbox.
- عناصر UI: بطاقات أدوار + اسم مستخدم + الجنس + المحافظة + تأكيد +18.
- الحالات: Checking username/Validation error.
- النصوص: "اختر دورك"، "اسم المستخدم متاح".
- التنقل: GoRouter إلى Profile Setup.
- Micro-interactions: Hero على البطاقات، Haptic عند الاختيار.

### D) Profile Setup (زبون/مصور)
- الهدف: إكمال ملف احترافي.
- Widgets: Scaffold, Stepper, Form, ImagePicker, GridView.
- عناصر UI: زبون (اهتمامات) + مصور (غلاف/نبذة/أسعار/معرض/توفر).
- الحالات: Uploading/Empty/Error/Success.
- النصوص: "أكمل ملفك"، "أضف صور المعرض".
- التنقل: GoRouter إلى Home.
- Micro-interactions: Slide بين الخطوات، Haptic عند إضافة صور.

### E) Home (Stories + Feed + Discover)
- الهدف: اكتشاف سريع للمصورين والمحتوى.
- Widgets: Scaffold, SliverAppBar, CustomScrollView, ListView.
- عناصر UI: قصص أعلى الشاشة + منشورات + أقسام اكتشاف.
- الحالات: Shimmer/Empty/Error.
- النصوص: "القصص"، "استكشف".
- التنقل: GoRouter إلى ملف مصور/منشور.
- Micro-interactions: Pull-to-refresh + Hero للصور.

### F) Search + Filters
- الهدف: بحث دقيق حسب المحافظة والنوع والتقييم.
- Widgets: SearchBar, FilterChips, ModalBottomSheet.
- عناصر UI: اقتراحات + فلاتر متقدمة + نتائج.
- الحالات: Searching/Empty/Error.
- النصوص: "ابحث عن مصور"، "تطبيق الفلاتر".
- التنقل: GoRouter إلى ملف المصور.
- Micro-interactions: Slide للفلتر + Haptic عند التطبيق.

### G) Photographer Profile
- الهدف: تحويل الزائر إلى حجز.
- Widgets: SliverAppBar, TabBar, GridView, CTAButton.
- عناصر UI: غلاف + نبذة + أسعار + تقييمات + معرض.
- الحالات: Loading/Empty/Error.
- النصوص: "متابعة"، "مراسلة"، "احجز الآن".
- التنقل: GoRouter إلى Booking/Chat.
- Micro-interactions: Hero للصور + Collapse للغلاف.

### H) Create Post
- الهدف: نشر محتوى اجتماعي.
- Widgets: Scaffold, AppBar, TextField, ImagePicker.
- عناصر UI: معاينة وسائط + وصف + وسوم.
- الحالات: Uploading/Error/Success.
- النصوص: "منشور جديد"، "نشر".
- التنقل: GoRouter إلى Home.
- Micro-interactions: SnackBar نجاح + Haptic.

### I) Create Story
- الهدف: نشر ستوري 24 ساعة.
- Widgets: FullScreenDialog, Stack, TextOverlay.
- عناصر UI: كاميرا/معرض + تعديل سريع.
- الحالات: Uploading/Error/Success.
- النصوص: "ستوري جديد"، "نشر".
- التنقل: رجوع إلى Home.
- Micro-interactions: Fade كامل الشاشة.

### J) Chat (Realtime)
- الهدف: تواصل لحظي ومشاركة ملفات.
- Widgets: Scaffold, ListView(reverse), TextField, BottomSheet.
- عناصر UI: فقاعات رسائل + مرفقات صور/فيديو/ملف.
- الحالات: Connecting/Empty/Error/Success.
- النصوص: "اكتب رسالة"، "إرفاق".
- التنقل: داخل المحادثة.
- Micro-interactions: AutoScroll + Haptic عند الإرسال.

### K) Booking Flow
- الهدف: حجز واضح خطوة بخطوة.
- Widgets: Stepper, CalendarDatePicker, TimePicker.
- عناصر UI: النوع + التاريخ/الوقت + الموقع + ملخص السعر.
- الحالات: تعارض مواعيد/فشل الإرسال.
- النصوص: "احجز جلسة"، "تأكيد الحجز".
- التنقل: GoRouter إلى الدفع.
- Micro-interactions: Slide بين الخطوات.

### L) Payment Flow
- الهدف: دفع آمن وسريع.
- Widgets: PaymentSheet, SummaryCard, Dialog.
- عناصر UI: تفاصيل المبلغ + وسيلة الدفع.
- الحالات: Processing/Failed/Success.
- النصوص: "الدفع"، "ادفع الآن".
- التنقل: رجوع لتفاصيل الحجز.
- Micro-interactions: Haptic نجاح + Dialog تأكيد.

### M) Reviews
- الهدف: جمع تقييمات بعد الجلسة.
- Widgets: RatingBar, TextField, CTAButton.
- عناصر UI: تقييم إجمالي + فرعي + تعليق.
- الحالات: Submitting/Error/Success.
- النصوص: "قيّم تجربتك"، "إرسال".
- التنقل: GoRouter إلى الملف/الحجز.
- Micro-interactions: Haptic عند تقييم النجوم.

### N) Notifications
- الهدف: إشعارات واضحة وسريعة.
- Widgets: ListView, Dismissible, Badge.
- عناصر UI: بطاقات إشعار + عداد غير مقروء.
- الحالات: Loading/Empty/Error.
- النصوص: "الإشعارات"، "تمييز كمقروء".
- التنقل: GoRouter حسب نوع الإشعار.
- Micro-interactions: Swipe للحذف.

### O) Photographer Dashboard
- الهدف: إدارة الأعمال والأداء.
- Widgets: TabBar, Charts, ListView.
- عناصر UI: KPIs + حجوزات قادمة.
- الحالات: Loading/Empty/Error.
- النصوص: "لوحة التحكم"، "الأرباح".
- التنقل: GoRouter إلى تفاصيل الحجز.
- Micro-interactions: Animated charts.

### P) Settings & Privacy
- الهدف: إدارة التفضيلات والخصوصية.
- Widgets: ListTile, Switch, Dialog.
- عناصر UI: اللغة، الثيم، الإشعارات، حذف الحساب.
- الحالات: Saving/Error/Success.
- النصوص: "الإعدادات"، "الخصوصية".
- التنقل: GoRouter إلى السياسات.
- Micro-interactions: Haptic عند التبديل.

### Q) Reports & Support
- الهدف: دعم وإبلاغ واضح.
- Widgets: Form, RadioListTile, TextField.
- عناصر UI: اختيار سبب + وصف + إرفاق.
- الحالات: Submitting/Error/Success.
- النصوص: "إبلاغ"، "أرسل البلاغ".
- التنقل: رجوع تلقائي مع رسالة نجاح.
- Micro-interactions: Dialog نجاح + Haptic.

## Design System (بدون أكواد)
- Color Palette: Primary #4DB6E5, Accent #FFA726, Dark #0B0E13, Surface #FFFFFF, Text #333333.
- Typography: Tajawal (AR) + Poppins (EN)، أحجام 32/24/20/18/16/14/12.
- Spacing: شبكة 4/8/12/16/24/32، هوامش 24.
- Reusable Widgets: Buttons, Inputs, Cards, Chips, Avatars, MediaGrid, EmptyState.
- الالتزام بـ Material 3 ودعم RTL/LTR مع تبديل فوري.
