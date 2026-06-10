# 🚀 دليل التحسينات العملية

## 1. Selector Pattern (تقليل Rebuilds)

### قبل ❌
```dart
Consumer<BookingProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        // يعاد بناؤها كل مرة
        ExpensivePhotographerCard(provider.photographer!),
        ExpensiveBookingDetails(provider.booking!),
        ExpensiveLocationMap(provider.location!),
        ExpensiveReviewsList(provider.reviews),
      ],
    );
  },
);
```

### بعد ✅
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      // كل واحد يعاد بناؤه فقط عند تغير بيانات خاصة به
      Selector<BookingProvider, UserProfile?>(
        selector: (_, provider) => provider.photographer,
        builder: (_, photographer, __) =>
          photographer == null ? SizedBox() : ExpensivePhotographerCard(photographer),
      ),
      
      Selector<BookingProvider, BookingModel?>(
        selector: (_, provider) => provider.booking,
        builder: (_, booking, __) =>
          booking == null ? SizedBox() : ExpensiveBookingDetails(booking),
      ),
      
      Selector<BookingProvider, LocationModel?>(
        selector: (_, provider) => provider.location,
        builder: (_, location, __) =>
          location == null ? SizedBox() : ExpensiveLocationMap(location),
      ),
      
      Selector<BookingProvider, List<Review>>(
        selector: (_, provider) => provider.reviews,
        builder: (_, reviews, __) => ExpensiveReviewsList(reviews),
      ),
    ],
  );
}
```

---

## 2. ListView Optimization

### قبل ❌
```dart
// بطيء جداً - يعاد رسم كل الـ list في كل تغيير
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) => MessageTile(message: messages[index]),
)
```

### بعد ✅
```dart
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) => MessageTile(
    message: messages[index],
    key: ValueKey(messages[index].id), // ← مهم جداً
  ),
  addRepaintBoundaries: true,
  addAutomaticKeepAlives: false, // إذا لم تحتج
  addSemanticIndexes: false,
  cacheExtent: 200, // استحضر 200px قبل وبعد viewport
)
```

---

## 3. Async Operations Parallel

### قبل ❌ (بطيء - متسلسل)
```dart
Future<void> _loadBookingDetails() async {
  final booking = await BookingDependencies.getBookingById().call(id);
  final photographer = await ProfileDependencies.getUserProfile().call(booking.photographerId);
  final reviews = await ReviewDependencies.getReviews().call(booking.photographerId);
  final delivery = await DeliveriesDependencies.getDelivery().call(booking.id);
  
  // الوقت الكلي = مجموع الأوقات الأربعة
}
```

### بعد ✅ (سريع - متوازي)
```dart
Future<void> _loadBookingDetails() async {
  try {
    final results = await Future.wait([
      BookingDependencies.getBookingById().call(id),
      ProfileDependencies.getUserProfile().call(booking.photographerId),
      ReviewDependencies.getReviews().call(booking.photographerId),
      DeliveriesDependencies.getDelivery().call(booking.id),
    ]).timeout(const Duration(seconds: 10));
    
    if (!mounted) return;
    
    setState(() {
      _booking = results[0];
      _photographer = results[1];
      _reviews = results[2];
      _delivery = results[3];
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _hasError = true);
  }
}
```

---

## 4. Image Optimization

### قبل ❌
```dart
// يحمل من الإنترنت في كل مرة، لا caching
Image.network(
  photographerUrl,
  width: 400,
  height: 400,
  fit: BoxFit.cover,
)
```

### بعد ✅
```dart
CachedNetworkImage(
  imageUrl: photographerUrl,
  width: 400,
  height: 400,
  fit: BoxFit.cover,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.grey),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  cacheManager: CacheManager.instance,
  memCacheWidth: 400, // حد أقصى للـ memory
  memCacheHeight: 400,
  fadeInDuration: Duration(milliseconds: 200),
)
```

---

## 5. Form Validation Optimization

### قبل ❌ (بطيء - يعيد build الـ form كاملة)
```dart
TextField(
  onChanged: (value) {
    setState(() {
      _emailError = validateEmail(value);
    });
  },
)
```

### بعد ✅ (سريع - debounce و selector)
```dart
class EmailField extends StatefulWidget {
  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  final _debouncer = Debouncer(milliseconds: 500);
  final _emailNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            _emailNotifier.value = value;
            _debouncer.run(() {
              // validate بعد 500ms فقط
              context.read<AuthProvider>().validateEmail(value);
            });
          },
        ),
        // استعمل ValueListenableBuilder بدل setState
        ValueListenableBuilder<String>(
          valueListenable: _emailNotifier,
          builder: (context, value, child) {
            final error = validateEmail(value);
            return error == null 
              ? SizedBox() 
              : Text(error, style: TextStyle(color: Colors.red));
          },
        ),
      ],
    );
  }
}
```

---

## 6. Const Widgets (مهم جداً!)

### قبل ❌
```dart
// لا استخدام const - يعاد إنشاء الـ widget في كل build
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Static Text'),
)
```

### بعد ✅
```dart
// استخدم const لكل الـ widgets الثابتة
const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Static Text'),
)
```

---

## 7. RepaintBoundary for Complex Widgets

### قبل ❌
```dart
// كل الـ widget يعاد رسمه
Container(
  child: CustomPainter(...), // معقد جداً
)
```

### بعد ✅
```dart
// استخدم RepaintBoundary لعزل الـ widget
RepaintBoundary(
  child: Container(
    child: CustomPainter(...),
  ),
)
```

---

## 8. Lazy Loading for Heavy Content

### قبل ❌
```dart
// تحميل جميع البيانات مرة واحدة
@override
void initState() {
  super.initState();
  _loadAllData();
}
```

### بعد ✅
```dart
// تحميل على الطلب فقط
class PhotographerGallery extends StatefulWidget {
  @override
  State<PhotographerGallery> createState() => _PhotographerGalleryState();
}

class _PhotographerGalleryState extends State<PhotographerGallery> {
  final List<Image> _loadedImages = [];
  bool _isLoadingMore = false;

  void _loadMoreImages() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    
    final newImages = await GalleryDependencies.getImages(
      offset: _loadedImages.length,
      limit: 20,
    );
    
    setState(() {
      _loadedImages.addAll(newImages);
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: _loadedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _loadedImages.length) {
          _loadMoreImages();
          return Center(child: CircularProgressIndicator());
        }
        return Image(image: _loadedImages[index]);
      },
    );
  }
}
```

---

## 9. Perfomance Monitoring

```dart
import 'dart:developer' as developer;

class PerformanceHelper {
  static Future<T> measurePerformance<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final timeline = developer.Timeline.startSync(name);
    
    try {
      final result = await operation();
      return result;
    } finally {
      timeline.finish();
    }
  }

  static void measureSync<T>(
    String name,
    T Function() operation,
  ) {
    final timeline = developer.Timeline.startSync(name);
    
    try {
      operation();
    } finally {
      timeline.finish();
    }
  }
}

// الاستخدام:
Future<void> _loadBooking() async {
  await PerformanceHelper.measurePerformance(
    'load_booking',
    () => BookingDependencies.getBookingById().call(id),
  );
}
```

---

## 10. Memory Leaks Prevention

```dart
class SafeAsyncScreen extends StatefulWidget {
  @override
  State<SafeAsyncScreen> createState() => _SafeAsyncScreenState();
}

class _SafeAsyncScreenState extends State<SafeAsyncScreen> {
  final List<StreamSubscription> _subscriptions = [];
  late Future<Data> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    
    // تسجيل الـ subscriptions للـ cleanup
    _subscriptions.add(
      SomeStream.listen((_) => setState(() {})),
    );
  }

  @override
  void dispose() {
    // تنظيف الـ subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingWidget();
        return DataDisplay(snapshot.data!);
      },
    );
  }
}
```

---

## ✅ Checklist التطبيق

- [ ] استخدام `Selector` في جميع `Consumer`
- [ ] استخدام `const` في جميع الـ widgets الثابتة
- [ ] استخدام `ListView.builder` بدل `ListView`
- [ ] استخدام `CachedNetworkImage` لكل الصور
- [ ] استخدام `Debouncer` للـ searches والـ validation
- [ ] استخدام `Future.wait` للـ parallel operations
- [ ] حذف جميع `print()` في production
- [ ] استخدام `RepaintBoundary` للـ complex widgets
- [ ] إضافة `key` في جميع الـ lists
- [ ] تنظيف الـ subscriptions في `dispose()`

---

**طبق هذه التحسينات لتحصل على أداء ⚡ رائعة!**
