# 🤝 دليل المساهمة - LAQTA

شكراً لاهتمامك بالمساهمة في LAQTA! 🎉

## 📋 قواعد السلوك

- احترم جميع المساهمين
- تواصل بشفافية وأمانة
- ركز على الكود وليس على الشخص

## 🚀 كيفية البدء

### 1. استنساخ المستودع
```bash
git clone https://github.com/e101t/laqta.git
cd laqta
```

### 2. إنشاء فرع جديد
```bash
git checkout -b feature/your-feature-name
# أو
git checkout -b fix/your-fix-name
# أو
git checkout -b refactor/your-refactor-name
```

### 3. إتباع معايير الأسماء

**Branches:**
- `feature/feature-name` - لـ features جديدة
- `fix/bug-name` - لـ bug fixes
- `refactor/change-name` - لـ refactoring
- `docs/update-name` - لـ توثيق

**Commits:**
```
verb: description

Example:
- "Add user authentication flow"
- "Fix timeout error in API client"
- "Refactor profile screen architecture"
```

## 🛠️ البيئة المطلوبة

```bash
# تثبيت التبعيات
flutter pub get

# إصلاح المشاكل المحتملة
flutter clean
flutter pub get

# التأكد من صحة الإعدادات
flutterfire configure
```

## ✅ قبل الـ Commit

```bash
# تشغيل التحليل
dart analyze

# تنسيق الكود
dart format lib/ test/

# تشغيل الاختبارات
flutter test

# بناء تجريبي
flutter build apk --debug
```

## 📝 كتابة الكود

### معايير الكود

- ✅ استخدم **Clean Architecture**
- ✅ اسم متغيرات واضح وذو معنى
- ✅ فصل المنطق عن الـ UI
- ✅ استخدم **Provider** لـ state management
- ✅ اكتب unit tests للـ business logic
- ✅ توثيق الدوال المعقدة

### مثال على structure صحيح

```
features/feature_name/
├── data/
│   ├── datasources/
│   ├── dtos/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── feature_name_dependencies.dart
```

## 🧪 الاختبارات

### كتابة اختبارات جديدة

```dart
void main() {
  group('Feature Description', () {
    setUp(() {
      // إعداد الاختبار
    });

    test('should do something when X happens', () {
      // arrange
      final input = ...;

      // act
      final result = sut.method(input);

      // assert
      expect(result, expectedValue);
    });
  });
}
```

### التغطية (Coverage)

الهدف: **80%+** coverage على business logic

```bash
flutter test --coverage
open coverage/index.html
```

## 📤 إنشاء Pull Request

### عنوان PR الجيد
```
feature: Add user authentication
fix: Resolve timeout error in API client
refactor: Simplify profile screen widget tree
```

### وصف PR

```markdown
## Summary
[وصف موجز للتغيير]

## Changes Made
- [تغيير 1]
- [تغيير 2]
- [تغيير 3]

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manually tested on device

## Checklist
- [ ] Code follows style guidelines
- [ ] No new warnings generated
- [ ] Tests pass locally
- [ ] Commit messages are clear
```

## 🔍 عملية المراجعة

1. **Automated Checks**
   - ✅ Lint analysis
   - ✅ Format check
   - ✅ Unit tests

2. **Code Review**
   - 👨‍💻 مراجعة يدوية من الفريق
   - 🎯 التأكد من اتباع المعايير
   - 💬 ملاحظات بناءة

3. **Approval & Merge**
   - ✅ موافقة من 2+ reviewers
   - ✅ جميع الاختبارات تمر
   - ✅ تحديث الـ changelog

## 🐛 الإبلاغ عن الأخطاء

### قالب Issue جيد

```markdown
## الوصف
[وصف واضح للخطأ]

## خطوات إعادة الإنتاج
1. افتح التطبيق
2. انتقل إلى [المكان]
3. اضغط على [الزر]
4. [الخطأ يحدث]

## السلوك المتوقع
[ما يجب أن يحدث]

## السلوك الفعلي
[ما يحدث بالفعل]

## البيئة
- Device: [نوع الجهاز]
- OS: [نسخة النظام]
- App Version: [إصدار التطبيق]

## Screenshot/Video
[إرفاق صورة أو فيديو إن أمكن]
```

## 📚 الموارد المفيدة

- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase Setup](https://firebase.flutter.dev/)

## 🎯 الأولويات

أولويات المساهمات:
1. **🔴 حرجة** - أخطاء في الإصدار الحالي
2. **🟠 عالية** - أخطاء مهمة
3. **🟡 متوسطة** - تحسينات
4. **🟢 منخفضة** - تحسينات UI إضافية

## 📞 الدعم

- **Questions?** - افتح Discussion في GitHub
- **Bug found?** - افتح Issue
- **Want to contribute?** - Discussions أو Direct Message

---

**شكراً لمساهمتك! 🙌**
