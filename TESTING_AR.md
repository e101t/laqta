# 🧪 دليل الاختبار - LAQTA

## نظرة عامة على الاختبارات

المشروع يحتوي على **3 أنواع من الاختبارات**:

1. **Unit Tests** - اختبار الدوال والـ logic المفصولة
2. **Widget Tests** - اختبار الـ widgets والـ UI
3. **Integration Tests** - اختبار التفاعل بين الأجزاء المختلفة

## 📊 هيكل الاختبارات

```
test/
├── app/
│   └── main_app_screen_test.dart
├── core/
│   ├── services/
│   │   └── backend_api_client_timeout_test.dart
│   ├── widgets/
│   │   └── mounted_lifecycle_test.dart
│   └── utils/
│       └── [other tests]
└── features/
    ├── auth/
    ├── profile/
    └── [other features]
```

## 🚀 تشغيل الاختبارات

### تشغيل جميع الاختبارات
```bash
flutter test
```

### تشغيل ملف اختبار محدد
```bash
flutter test test/app/main_app_screen_test.dart
```

### تشغيل اختبار محدد
```bash
flutter test --name="MainAppScreen"
```

### مع Coverage Report
```bash
flutter test --coverage
```

### عرض التغطية
```bash
# على macOS/Linux
open coverage/index.html

# على Windows
start coverage/index.html
```

## ✍️ كتابة Unit Tests

### مثال أساسي

```dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockUserDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockUserDataSource();
      repository = UserRepository(mockDataSource);
    });

    test('getUser returns user when call is successful', () async {
      // Arrange
      const userId = 'user123';
      final userModel = UserModel(id: userId, name: 'John');
      when(() => mockDataSource.getUser(userId))
          .thenAnswer((_) async => userModel);

      // Act
      final result = await repository.getUser(userId);

      // Assert
      expect(result, equals(userModel));
      verify(() => mockDataSource.getUser(userId)).called(1);
    });

    test('getUser throws exception on error', () async {
      // Arrange
      const userId = 'user123';
      when(() => mockDataSource.getUser(userId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getUser(userId),
        throwsException,
      );
    });
  });
}
```

## 🎯 كتابة Widget Tests

### مثال Widget Test

```dart
void main() {
  group('ProfileScreen', () {
    testWidgets('displays user profile correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('shows error message on failure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ErrorWidget), findsOneWidget);
    });
  });
}
```

## 🧩 Mocking مع Mocktail

### إعداد Mocks

```dart
import 'package:mocktail/mocktail.dart';

// إنشاء mock class
class MockUserRepository extends Mock implements UserRepository {}

// في الاختبار
void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
  });

  test('example', () {
    // إعداد السلوك
    when(() => mockRepository.getUser('123'))
        .thenAnswer((_) async => UserModel(id: '123'));

    // التحقق من الاستدعاء
    verify(() => mockRepository.getUser('123')).called(1);
  });
}
```

## 📈 معايير التغطية

### الأهداف
- **Overall**: 75%+
- **Business Logic**: 90%+
- **UI Widgets**: 60%+
- **Services**: 85%+

### التحقق من التغطية

```bash
# توليد التقرير
flutter test --coverage

# عرض التقرير
cd coverage && open index.html
```

## 🔄 Integration Tests

### مثال Integration Test

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Flow', () {
    testWidgets('Complete booking flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for photographer
      await tester.enterText(find.byType(TextField), 'photographer');
      await tester.pumpAndSettle();

      // Verify results
      expect(find.byType(PhotographerCard), findsWidgets);
    });
  });
}
```

## 🚦 CI/CD Testing

### GitHub Actions

المشروع يشغل الاختبارات تلقائياً على كل:
- **Pull Request** - يجب أن تمر جميع الاختبارات
- **Push to Master** - تقارير تفصيلية
- **Release** - اختبارات شاملة

### ملف Workflow

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter test --coverage
    - run: codecov/codecov-action@v3
```

## 🎨 Best Practices

### ✅ افعل
- ✅ كتابة اختبار قبل الكود (TDD)
- ✅ اختبر الحالات الاستثنائية
- ✅ استخدم اسماء واضحة للاختبارات
- ✅ اجعل الاختبار independent
- ✅ استخدم setUp و tearDown

### ❌ لا تفعل
- ❌ اختبار implementation details
- ❌ اختبارات بطيئة جداً
- ❌ اختبارات عشوائية النتائج
- ❌ اختبارات معقدة جداً
- ❌ تخطي الاختبارات الفاشلة

## 📝 أمثلة اختبارات موجودة

```
test/
├── app/main_app_screen_test.dart              # Role caching tests
├── core/services/backend_api_client_timeout_test.dart  # Timeout tests
└── core/widgets/mounted_lifecycle_test.dart   # Widget lifecycle tests
```

## 🔧 استكشاف الأخطاء

### الاختبار لا يمر

```bash
# تشغيل مع verbose output
flutter test -v

# تشغيل مع debug output
flutter test --verbose --debug
```

### الاختبار معلق

```bash
# إضافة timeout
test('my test', () async {
  testWidgets('hangs', (tester) async {
    // ...
  }, timeout: Timeout(Duration(seconds: 30)));
});
```

### الاختبار غير مستقر

```dart
// استخدم pumpAndSettle بدلاً من pump
await tester.pumpAndSettle();

// أو حدد عدد التكرارات
await tester.pumpAndSettle(
  Duration(milliseconds: 100),
  EnginePhase.sendSemanticsUpdate,
  Duration(seconds: 10),
);
```

---

**Happy Testing! 🚀**
