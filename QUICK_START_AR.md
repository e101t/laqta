# ⚡ البدء السريع - LAQTA

## 5 دقائق فقط! ⏱️

### الخطوة 1: استنساخ المستودع
```bash
git clone https://github.com/e101t/laqta.git
cd laqta
```

### الخطوة 2: تثبيت التبعيات
```bash
flutter pub get
```

### الخطوة 3: إعداد Firebase
```bash
flutterfire configure
```

### الخطوة 4: التشغيل
```bash
flutter run
```

✅ **تم! التطبيق جاهز!**

---

## 🎯 الخطوات التالية

### تشغيل الاختبارات
```bash
flutter test
```

### بناء APK
```bash
flutter build apk --release
```

### تصفح الكود
- **الـ UI**: `lib/features/*/presentation/screens/`
- **الـ Logic**: `lib/features/*/domain/usecases/`
- **الخدمات**: `lib/core/services/`

### الموارد المهمة
- 📖 [ARCHITECTURE.md](ARCHITECTURE_AR.md) - البنية المعمارية
- 🧪 [TESTING.md](TESTING_AR.md) - الاختبارات
- 🤝 [CONTRIBUTING.md](CONTRIBUTING_AR.md) - المساهمة

---

## 🐛 حل المشاكل الشائعة

### خطأ: "Flutter not found"
```bash
# تحديث Flutter
flutter upgrade

# أو تثبيت Flutter
# من https://flutter.dev/docs/get-started/install
```

### خطأ: "Firebase configuration missing"
```bash
flutterfire configure
```

### خطأ: "Gradle build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### بطء الـ build الأول
- ✅ هذا طبيعي! الـ build الأول يأخذ وقت
- الـ builds اللاحقة ستكون أسرع بـ 80%

---

## 📱 الأجهزة المدعومة

- ✅ Android 6.0+ (API 23+)
- ✅ iOS 11.0+
- ✅ Web (تجريبي)

---

**مرحباً بك في LAQTA! 🚀**
