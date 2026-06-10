# 🔐 دليل الأمان - LAQTA

## معايير الأمان

### ✅ المطبقة
- ✅ Firebase Authentication
- ✅ Secure Storage (للبيانات الحساسة)
- ✅ HTTPS فقط
- ✅ Input Validation
- ✅ Token Management
- ✅ Error Handling آمن

---

## 🔑 إدارة التوكنات

### عدم حفظ التوكن في SharedPreferences
```dart
// ❌ خطأ
prefs.setString('authToken', token);  // غير آمن!

// ✅ صحيح
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'authToken', value: token);
```

### استخدام التوكن بشكل آمن
```dart
final token = await secureStorage.read(key: 'authToken');
final response = await http.get(
  Uri.parse('https://api.laqta.dev/user'),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

## 🛡️ Input Validation

### التحقق من المدخلات
```dart
// Email validation
if (!email.contains('@')) {
  throw ValidationException('Invalid email');
}

// Phone validation
if (phone.length != 11 || !phone.startsWith('07')) {
  throw ValidationException('Invalid phone');
}

// Amount validation
if (amount <= 0) {
  throw ValidationException('Invalid amount');
}
```

### SQL Injection Protection
```dart
// ❌ خطر
final query = "SELECT * FROM users WHERE id = '$userId'";

// ✅ آمن (Firestore يحمي تلقائياً)
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
```

---

## 🔐 حفظ البيانات الحساسة

### استخدام Secure Storage
```dart
class TokenManager {
  static final _secureStorage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'authToken');
  }
}
```

### عدم حفظ البيانات الحساسة في Logs
```dart
// ❌ خطر
print('User token: $token');

// ✅ آمن
logger.info('Token saved successfully');  // بدون قيمة التوكن
```

---

## 🌐 HTTPS فقط

```dart
class BackendApiClient {
  static const String _baseUrl = 'https://api.laqta.dev';  // HTTPS فقط!

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    return http.get(uri);
  }
}
```

---

## 🔍 منع XSS و Injection

### تنظيف المدخلات
```dart
String sanitizeInput(String input) {
  return input
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;');
}
```

### عدم تنفيذ الكود من المستخدمين
```dart
// ❌ خطر جداً
eval(userInput);

// ✅ آمن
if (userInput == 'valid_command') {
  executeCommand();
}
```

---

## 🛡️ معالجة الأخطاء الآمنة

### عدم كشف معلومات حساسة
```dart
// ❌ خطر
catch (e) {
  print('Error: ${e.toString()}');  // قد يكشف معلومات حساسة
}

// ✅ آمن
catch (e) {
  logger.error('Operation failed');
  showUserFriendlyError('حدث خطأ. حاول مرة أخرى.');
}
```

---

## 🔐 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // المستخدمون يمكنهم قراءة وكتابة بيانات أنفسهم فقط
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // الحجوزات
    match /bookings/{bookingId} {
      allow read, write: if request.auth.uid in resource.data.participants;
    }

    // الرسائل
    match /messages/{messageId} {
      allow read, write: if request.auth.uid in resource.data.participants;
    }
  }
}
```

---

## 📱 Platform-Specific Security

### Android
- ✅ استخدام `android:usesCleartextTraffic="false"`
- ✅ تفعيل ProGuard/R8
- ✅ استخدام Biometric authentication

### iOS
- ✅ استخدام Keychain
- ✅ تفعيل Face ID/Touch ID
- ✅ استخدام Code Signing

---

## ✅ Security Checklist

- [ ] جميع الـ requests على HTTPS
- [ ] التوكنات في Secure Storage
- [ ] Input validation دائماً
- [ ] Error handling بدون كشف معلومات
- [ ] Firestore rules محمية
- [ ] Passwords encrypted
- [ ] Sensitive logs مخفية
- [ ] API keys آمنة (في environment variables)
- [ ] Updates الأمان تطبق فوراً
- [ ] Security audit دوري

---

## 📚 الموارد

- [Flutter Security Best Practices](https://flutter.dev/docs/testing/common-errors)
- [OWASP Top 10 Mobile](https://owasp.org/www-project-mobile-app-security/)
- [Firebase Security](https://firebase.google.com/docs/security)

---

**الأمان أولاً! 🔐**
