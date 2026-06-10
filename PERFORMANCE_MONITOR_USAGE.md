# 📊 كيفية استخدام Performance Monitor

## التهيئة في main.dart

```dart
import 'package:laqta/core/monitoring/performance_monitor.dart';

void main() {
  PerformanceMonitor().initialize();
  
  runApp(const MyApp());
}
```

## 1. قياس عملية متزامنة

```dart
Future<void> _loadBooking() async {
  await PerformanceMonitor().measureAsync(
    'load_booking',
    () => BookingDependencies.getBookingById().call(id),
    warningThreshold: Duration(milliseconds: 500),
  );
}
```

## 2. قياس عملية متزامنة

```dart
void _parseData() {
  PerformanceMonitor().measureSync(
    'parse_json',
    () {
      // عملية معقدة
      return jsonDecode(response);
    },
    warningThreshold: Duration(milliseconds: 50),
  );
}
```

## 3. الحصول على التقرير

```dart
void _showPerformanceReport() {
  final report = PerformanceMonitor().getReport();
  debugPrint(report);
  
  // أو احفظه في ملف
  // writeToFile(report);
}
```

## 4. الـ Debouncer

```dart
final _debouncer = Debouncer(milliseconds: 500);

TextField(
  onChanged: (value) {
    _debouncer.run(() {
      context.read<SearchProvider>().search(value);
    });
  },
)
```

## 5. مثال عملي كامل

```dart
class BookingDetailsScreen extends StatefulWidget {
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Future<void> _loadData() async {
    await PerformanceMonitor().measureAsync(
      'booking_load',
      () => Future.wait([
        _loadBooking(),
        _loadPhotographer(),
        _loadReviews(),
      ]),
      warningThreshold: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget();
        }
        return BookingDetails();
      },
    );
  }
}
```

## 6. DevTools Integration

```dart
// في settings.json أو environment
void enablePerformanceMonitoring() {
  if (kDebugMode) {
    Timer(Duration(seconds: 10), () {
      final report = PerformanceMonitor().getReport();
      debugPrint(report);
    });
  }
}
```

---

✅ الآن يمكنك قياس أداء التطبيق بدقة!
