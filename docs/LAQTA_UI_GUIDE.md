# LAQTA UI/UX Guide — Minimal + Glassmorphism + Parallax

هذه الوثيقة مرجعية لتنفيذ واجهات LAQTA بأسلوب Minimal مع Glassmorphism محدود وParallax مخصص للملف الشخصي للمصور.

==================================================
1) الهوية العامة للتصميم (Design System)
==================================================

## A) Theme Tokens
- الألوان (Color Tokens)
  - Primary: #4DB6E5
  - Accent:  #FFA726
  - Ink (Text): #0E1116
  - InkMuted: #6B7280
  - Canvas: #F7F8FA
  - Surface: #FFFFFF
  - Border: #E6E8EC
  - Success: #28C76F
  - Warning: #F2B705
  - Error: #E74C3C

- الحواف (Radii)
  - xs: 8
  - s: 12
  - m: 16
  - l: 24
  - xl: 32

- الظلال (Shadows)
  - soft: blur 16 / opacity 0.08
  - glass: blur 24 / opacity 0.12

- شفافية Glass + Blur Rules
  - GlassOpacity: 0.12–0.18
  - GlassBorderOpacity: 0.24–0.32
  - BlurSigma: 12–18

## B) Typography Scale
- TitleLarge: 24/32
- Title: 20/28
- Subtitle: 16/24
- Body: 14/22
- Caption: 12/18
- Arabic: Tajawal
- English: Poppins

## C) Spacing System
- xs: 4
- s: 8
- m: 12
- l: 16
- xl: 24
- xxl: 32

## D) قواعد Glass وParallax
- Glass يُستخدم فقط في: Stories + Feed Cards + BottomSheets/Modals.
- يُمنع Glass في: شاشات الإعدادات والنماذج الطويلة.
- Parallax يُستخدم فقط في: Profile Header + Cover + معرض الأعمال.
- لا يُستخدم Parallax في Home/Feed لتجنب إزعاج الحركة.

==================================================
2) مكونات UI المعاد استخدامها (Reusable Widgets)
==================================================

- LAQTAAppBar
  - الاستخدام: AppBar Minimal مع إشعارات + Avatar.
  - props: title, subtitle?, onNotificationsTap?, onAvatarTap?, showAvatar.
  - حالات: normal/pressed/disabled.
  - نصوص عربية: "الإشعارات"، "الملف الشخصي".

- LAQTABottomNav
  - الاستخدام: تنقل سفلي 4 تبويبات.
  - props: currentIndex, onTap, badges?.
  - حالات: normal/active.
  - نصوص: "الرئيسية"، "بحث"، "المحادثات"، "حسابي".

- LAQTAButton
  - الاستخدام: زر أساسي/ثانوي/نصي.
  - props: label, variant, onPressed, isLoading, icon?.
  - حالات: normal/pressed/disabled/loading.
  - نصوص: "ابدأ الآن"، "متابعة"، "حفظ".

- LAQTAInput
  - الاستخدام: TextField مع حالات التحقق.
  - props: label, hint, controller, errorText?, isRequired.
  - حالات: normal/focused/error/disabled.
  - نصوص: "أدخل الاسم"، "رقم الهاتف".

- GlassCard
  - الاستخدام: بطاقات الزجاج في القصص/المنشورات.
  - props: child, padding, radius, opacity, blur.
  - حالات: normal/pressed.
  - نصوص: بدون نص ثابت.

- StoryBubble
  - الاستخدام: فقاعة ستوري (جديد/مشاهد/إضافة).
  - props: imageUrl?, title, isViewed, isAdd.
  - حالات: normal/pressed/disabled.
  - نصوص: "إضافة".

- PostCard
  - الاستخدام: منشور ضمن Feed (Glass).
  - props: authorName, imageUrl, caption, onLike?, onShare?.
  - حالات: normal/pressed/disabled.
  - نصوص: "أعجبني"، "مشاركة".

- PhotographerCard
  - الاستخدام: بطاقة مصور في Discover.
  - props: name, rating, price, location, onTap?.
  - حالات: normal/pressed.
  - نصوص: "عرض الملف".

- EmptyState / ErrorState / LoadingSkeleton
  - الاستخدام: حالات القائمة.
  - props: title, message, onRetry?.
  - نصوص: "لا توجد نتائج"، "حدث خطأ".

- ChipsFilter
  - الاستخدام: فلاتر سريعة.
  - props: labels, selectedIndex, onSelected.
  - حالات: normal/selected.
  - نصوص: حسب الفلاتر.

- RatingRow
  - الاستخدام: عرض نجوم التقييم.
  - props: rating, count?.

- PriceTag
  - الاستخدام: إظهار السعر.
  - props: amount, currency.

- ProfileHeaderParallax
  - الاستخدام: Header للمصور مع Parallax.
  - props: coverUrl, avatarUrl, name, location, actions.

==================================================
3) الشاشات المطلوبة (Screens)
==================================================

A) SplashScreen
- هدف: عرض الشعار بواجهة Minimal.
- حالات: Loading فقط.
- Micro: Fade خفيف.

B) LanguageSelectScreen
- هدف: تحديد اللغة لأول مرة.
- حالات: اختيار مباشر + حفظ.
- Micro: Haptic على الاختيار.

C) OnboardingScreen
- هدف: PageView بثلاث شرائح.
- حالات: Skip/Next.

D) AuthScreen
- Tabs: تسجيل/دخول + Phone OTP + Google/Apple.
- حالات: Loading/Error/Success.

E) OTPScreen
- هدف: إدخال OTP.
- حالات: Wrong OTP/Resend.

F) RoleSelectScreen
- هدف: اختيار الدور.

G) BasicIdentityScreen
- username + gender + 18+ + province.

H) ProfileSetupCustomerScreen
- تفضيلات الزبون.

I) ProfileSetupPhotographerScreen
- cover/avatar/bio/regions/categories/prices/portfolio/equipment/availability/social.

J) HomeScreen
- Stories row (Glass)
- Feed list (Glass PostCard)
- Discover section (Minimal cards)

K) SearchScreen
- Search field
- Filters bottom sheet (Glass)

L) ChatListScreen + ChatRoomScreen
- Minimal مع حالات القراءة.

M) PhotographerProfileScreen
- Parallax header
- Tabs (Works/Posts/Reviews/Locations/Highlights)
- CTA ثابت "احجز الآن"

N) CreatePostScreen
- photo/equipment/location.

O) CreateStoryScreen
- photo/video 24h + preview.

P) BookingScreen
- date/time/type/location/notes/price + review.

Q) PaymentScreen
- partial/full + success/fail.

R) ReviewsScreen
- بعد الجلسة فقط.

S) NotificationsScreen
- قائمة بسيطة مع badge.

T) PhotographerDashboardScreen
- bookings/availability/stats/prices/gallery.

U) SettingsScreen
- profile/privacy/language/notifications/block/delete/logout.

V) ReportsSupportScreen
- نموذج دعم وإبلاغ.

==================================================
4) منطق التنقل (Navigation)
==================================================
- GoRouter مع Guards:
  - غير مسجل → Auth.
  - مسجل لكن غير مكتمل → Profile Setup.
  - مكتمل → Home.
- Back behavior:
  - من Payment يرجع إلى Booking Details فقط.
  - من Booking يرجع إلى Profile.

==================================================
5) نصوص عربية افتراضية (Microcopy)
==================================================
- Buttons: ابدأ الآن، متابعة، احجز الآن، إرسال، حفظ، مشاركة، إلغاء.
- Empty: لا توجد منشورات، لا توجد رسائل، لا توجد نتائج.
- Errors: فشل الاتصال، حدث خطأ، رمز غير صحيح.
- Toasts: تم الحفظ، تم النسخ، تم الإرسال.
- Booking/Payment: تم تأكيد الحجز، تم الدفع بنجاح، فشل الدفع.

==================================================
6) هيكل الملفات المقترح (Feature-Based)
==================================================
lib/
  design_system/
    laqta_tokens.dart
    laqta_typography.dart
    laqta_spacing.dart
    laqta_theme.dart
  ui/
    laqta_app_bar.dart
    laqta_bottom_nav.dart
    laqta_button.dart
    laqta_input.dart
    glass_card.dart
    story_bubble.dart
    post_card.dart
    photographer_card.dart
    chips_filter.dart
    rating_row.dart
    price_tag.dart
    states.dart
    profile_header_parallax.dart
  features/
    home/presentation/screens/home_glass_screen.dart
    photographer/presentation/screens/photographer_profile_screen.dart

ملاحظة: الشاشات الأساسية (Home/Profile) هي الأكثر تميزاً بصرياً مع Glass + Parallax.
