# LAQTA - Photography Booking Platform

[![Flutter CI](https://github.com/e101t/laqta/actions/workflows/ci.yml/badge.svg)](https://github.com/e101t/laqta/actions/workflows/ci.yml)
[![Master CI/CD](https://github.com/e101t/laqta/actions/workflows/master-ci.yml/badge.svg)](https://github.com/e101t/laqta/actions/workflows/master-ci.yml)

## 🎯 نظرة عامة

**LAQTA** هي منصة حجز تصوير فوتوغرافي متطورة تربط العملاء مع المصورين المحترفين في العراق. التطبيق مبني بـ Flutter ويوفر تجربة سلسة وآمنة للطرفين.

### المميزات الرئيسية

- 📷 استكشاف وحجز المصورين المحترفين
- 💬 نظام الرسائل المباشرة
- 💳 نظام الدفع آمن (Stripe)
- 📍 خريطة تفاعلية (Google Maps)
- ⭐ نظام التقييمات والمراجعات
- 🔐 مصادقة آمنة (Firebase Auth)
- 🌙 دعم الوضع الليلي
- 🌐 دعم العربية والإنجليزية

## 🏗️ البنية المعمارية

المشروع يتبع **Clean Architecture** مع تقسيم حسب Features:

```
lib/
├── app/                    # طبقة التطبيق
│   ├── main_app_screen.dart
│   └── router/            # التوجيه والملاحة
├── core/                   # الخدمات المشتركة
│   ├── services/          # الخدمات (API, Storage, etc)
│   ├── widgets/           # الـ widgets المعاد استخدامها
│   ├── theme/             # التصميم والألوان
│   ├── network/           # الاتصال والـ connectivity
│   └── utils/             # الأدوات والمساعدات
└── features/              # الميزات المنفصلة
    ├── auth/
    ├── profile/
    ├── booking/
    ├── chat/
    ├── payments/
    └── ... (33 feature أخرى)
```

## 🚀 البدء السريع

### المتطلبات
- Flutter 3.9.2+
- Dart 3.5.0+
- Java 17+ (للـ Android)
- Xcode 15+ (للـ iOS)
- Firebase Project

### التثبيت

1. **استنساخ المستودع**
```bash
git clone https://github.com/e101t/laqta.git
cd laqta
```

2. **تثبيت التبعيات**
```bash
flutter pub get
```

3. **إعداد Firebase**
```bash
flutterfire configure
```

4. **تشغيل التطبيق**
```bash
flutter run
```

## 📊 الميزات المطبقة مؤخراً

### تحسينات الأداء والاستقرار (Commit: 14f1857)

- ⚡ **تخزين مؤقت للـ Role** - تسريع بدء التطبيق بـ 2-3 ثواني
- 🔒 **مهلات زمنية للطلبات** - 20 ثانية للطلبات، 60 ثانية لرفع الملفات
- 🛡️ **فحوصات Widget Lifecycle** - منع `setState() after dispose()` errors
- 🎨 **تحسينات بصرية** - تحسينات على الظلال والرسوميات
- 📊 **معالجة أخطاء محسّنة** - fallback values عند فشل الاتصال

## 🧪 الاختبارات

المشروع يحتوي على **47+ اختبار** موزعة على:
- Unit Tests
- Widget Tests
- Integration Tests

### تشغيل الاختبارات

```bash
# تشغيل كل الاختبارات
flutter test

# تشغيل اختبارات محددة
flutter test test/app/main_app_screen_test.dart

# مع coverage report
flutter test --coverage
```

## 📱 البناء والإطلاق

### بناء APK
```bash
# debug
flutter build apk --debug

# release
flutter build apk --release
```

### بناء App Bundle (لـ Google Play)
```bash
flutter build appbundle --release
```

### بناء iOS
```bash
flutter build ios --release
```

## 🔄 CI/CD Pipeline

المشروع يستخدم **GitHub Actions** لـ CI/CD:

- **ci.yml** - اختبار وتحليل الكود على كل PR
- **flutter_ci.yml** - بناء Flutter-specific checks
- **master-ci.yml** - عمليات شاملة على master branch
- **release.yml** - أتمتة الإطلاق

## 📦 التبعيات الرئيسية

### State Management
- **provider** 6.1.1 - إدارة الحالة

### Backend & Firebase
- **firebase_core** 4.2.1
- **firebase_messaging** 16.0.2

### UI/UX
- **cached_network_image** 3.3.1
- **shimmer** 3.0.0
- **video_player** 2.8.2

### Networking & Storage
- **http** 1.2.1
- **shared_preferences** 2.2.2
- **flutter_secure_storage** 10.3.0

### Maps & Location
- **google_maps_flutter** 2.4.3

### Payment
- **flutter_stripe** 12.1.1

جميع التبعيات موثقة في `pubspec.yaml`

## 🔐 الأمان

- ✅ استخدام Firebase Authentication
- ✅ تشفير البيانات الحساسة (Secure Storage)
- ✅ HTTPS connections فقط
- ✅ input validation على جميع المدخلات
- ✅ منع من SQL injection و XSS
- ✅ Sentry integration للـ error tracking

## 📝 الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE)

## 👥 الإسهام

نرحب بالمساهمات! الرجاء اتباع [CONTRIBUTING.md](CONTRIBUTING.md)

## 📞 التواصل

- **البريد الإلكتروني**: support@laqta.dev
- **الموقع**: https://laqta.dev
- **Instagram**: [@laqta_app](https://instagram.com/laqta_app)

## 🗺️ Roadmap

- [ ] دعم ملفات الفيديو 4K
- [ ] نظام الدفع بالتقسيط
- [ ] تطبيق ويب مكامل
- [ ] دعم المزيد من طرق الدفع
- [ ] توسع لدول الخليج
- [ ] نظام الإحالة والمكافآت

---

صُنع بـ ❤️ من قبل فريق LAQTA
