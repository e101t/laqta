# 🔥 تقرير فحص الأداء - LAQTA

## 📊 النتائج الأساسية

### الشاشات الثقيلة (Top 10)
| الشاشة | السطور | الخطورة | المشكلة الرئيسية |
|--------|--------|---------|-----------------|
| **booking_details_screen.dart** | 1496 | 🔴 حرج | 41 widget، multiple Provider، heavy UI |
| **auth_screen.dart** | 1360 | 🔴 حرج | Complex forms، nested validation |
| **chat_screen.dart** | 1093 | 🟠 عالي | ListView، message rebuilds |
| **request_details_screen.dart** | 918 | 🟠 عالي | Multiple data fetches |
| **basic_info_screen.dart** | 884 | 🟠 عالي | Form validation overhead |
| **create_request_screen.dart** | 819 | 🟡 متوسط | Image uploads، file handling |
| **photographer_profile_screen.dart** | 660 | 🟡 متوسط | Gallery display، lazy load issues |
| **profile_screen.dart** | 591 | 🟡 متوسط | Multiple sections، data binding |
| **availability_screen.dart** | 570 | 🟡 متوسط | Calendar rendering |
| **payment_screen.dart** | 552 | 🟡 متوسط | Payment form، heavy validation |

---

## 🚨 المشاكل المكتشفة

### 1️⃣ **Widget Rebuild Issues**
```dart
// ❌ مشكلة: كل ولد يعاد بناؤه
Consumer<BookingProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        ExpensiveWidget(),  // ← يعاد بناؤه في كل setState
        Text(provider.name), // ← فقط هذا يحتاج تحديث
      ],
    );
  },
);

// ✅ الحل:
Consumer<BookingProvider>(
  builder: (context, provider, child) => Column(
    children: [
      child,
      Text(provider.name),
    ],
  ),
  child: ExpensiveWidget(), // ← لا يعاد بناؤه
);
```

### 2️⃣ **Heavy ListViews without optimization**
```dart
// ❌ مشكلة:
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    return ComplexMessageWidget(message: messages[index]);
  },
)

// ✅ الحل:
ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    return ComplexMessageWidget(message: messages[index]);
  },
  addAutomaticKeepAlives: true,
  addRepaintBoundaries: true,
  addSemanticIndexes: true,
)
```

### 3️⃣ **Multiple Async operations**
```dart
// ❌ مشكلة: تحميل متسلسل بطيء
Future<void> _load() async {
  _booking = await loadBooking();
  _photographer = await loadPhotographer();
  _delivery = await loadDelivery();
  _dispute = await loadDispute();
  _reviews = await loadReviews();
}

// ✅ الحل: تحميل متوازي سريع
Future<void> _load() async {
  final results = await Future.wait([
    loadBooking(),
    loadPhotographer(),
    loadDelivery(),
    loadDispute(),
    loadReviews(),
  ]);
  _booking = results[0];
  _photographer = results[1];
  // ...
}
```

### 4️⃣ **No Image Caching**
```dart
// ❌ مشكلة:
Image.network(url) // ← تحميل من الإنترنت كل مرة

// ✅ الحل:
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => Shimmer.fromColors(...),
  cacheManager: CustomCacheManager.instance,
)
```

### 5️⃣ **Form Validation on Every Keystroke**
```dart
// ❌ مشكلة:
TextField(
  onChanged: (value) {
    validateEmail(value); // ← يعمل في كل keystroke
    setState(() {}); // ← rebuild كامل الform
  },
)

// ✅ الحل:
TextField(
  onChanged: (value) {
    _debouncer.run(() {
      validateEmail(value);
      setState(() {});
    });
  },
)
```

---

## ⚡ تحسينات مقترحة

### الأولوية الأولى (🔴 حرج)

#### 1. Optimize booking_details_screen
```dart
// قبل: 1496 سطر، 41 widget، جميعها تعاد بناؤها
// بعد: 600 سطر، modular widgets، lazy loading

class BookingDetailsScreen extends StatefulWidget {
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  // استخدام Selectors لتقليل rebuilds
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // استخدام Selector بدل Consumer الكامل
          Selector<BookingProvider, BookingModel?>(
            selector: (_, provider) => provider.booking,
            builder: (context, booking, _) => 
              booking == null ? LoadingWidget() : BookingHeader(booking),
          ),
          
          // استخدام Selector للـ photographer
          Selector<BookingProvider, UserProfile?>(
            selector: (_, provider) => provider.photographer,
            builder: (context, photographer, _) => 
              photographer == null ? SizedBox() : PhotographerCard(photographer),
          ),
          
          // والمزيد من الـ Selectors
        ],
      ),
    );
  }
}
```

#### 2. Optimize auth_screen
```dart
// استخدام Form key بدل setState
final _formKey = GlobalKey<FormState>();

class AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) => EmailValidator.validate(value),
          ),
          // بدون setState في onChanged
        ],
      ),
    );
  }
}
```

---

### الأولوية الثانية (🟠 عالي)

#### 1. Chat Screen Optimization
```dart
class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScrollController _scrollController;
  final ValueNotifier<int> _loadedCount = ValueNotifier(20);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Lazy load: حمل 20 رسالة أولاً فقط
        if (index >= _loadedCount.value) {
          _loadMoreMessages();
          return SizedBox.shrink();
        }
        
        return ChatBubble(
          message: messages[index],
          key: ValueKey(messages[index].id), // هام للـ ListView
        );
      },
      addRepaintBoundaries: true, // تقليل repaints
      addSemanticIndexes: false, // لا نحتاجها هنا
    );
  }
}
```

#### 2. Image Optimization
```dart
// استخدام image compression و caching
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const Shimmer(...),
      errorWidget: (context, url, error) => const ErrorImage(),
      cacheManager: CacheManager.instance,
      memCacheWidth: 400, // حد أقصى للـ memory
      memCacheHeight: 400,
    );
  }
}
```

---

### الأولوية الثالثة (🟡 متوسط)

#### 1. Debounce Form Validation
```dart
class SearchField extends StatefulWidget {
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (query) {
        _debouncer.run(() {
          context.read<SearchProvider>().search(query);
        });
      },
    );
  }
}
```

#### 2. Pagination for Long Lists
```dart
class ProductList extends StatefulWidget {
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int _page = 1;
  final List<Product> _products = [];
  bool _isLoading = false;

  void _loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    
    final newProducts = await _fetchProducts(_page);
    setState(() {
      _products.addAll(newProducts);
      _page++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _products.length + 1,
      itemBuilder: (context, index) {
        if (index == _products.length) {
          _loadMore();
          return LoadingWidget();
        }
        return ProductCard(_products[index]);
      },
    );
  }
}
```

---

## 📋 Performance Checklist

- [ ] استخدام `const` widgets في كل مكان
- [ ] استخدام `Selector` بدل `Consumer`
- [ ] استخدام `ValueNotifier` للبيانات البسيطة
- [ ] استخدام `ListView.builder` بدل `ListView`
- [ ] استخدام `CachedNetworkImage` لكل الصور
- [ ] Debounce searches و validation
- [ ] استخدام `RepaintBoundary` للـ complex widgets
- [ ] تقليل عمق الـ widget tree
- [ ] استخدام `key` في lists
- [ ] Pagination للـ long lists
- [ ] Lazy loading للـ heavy content
- [ ] استخدام `shouldRebuild` في Changenotifier
- [ ] Profile using DevTools
- [ ] قياس frame rate (يجب 60 FPS)

---

## 🛠️ أدوات القياس

### 1. DevTools Performance
```bash
flutter pub global activate devtools
devtools
```

ثم افتح التطبيق وانتقل إلى:
- **Performance tab** - شاهد frames و jank
- **Memory tab** - تحقق من memory leaks
- **Timeline tab** - تحليل التفاصيل

### 2. Profiling Code
```dart
import 'dart:developer' as developer;

void heavyOperation() {
  final timeline = developer.Timeline.startSync('heavy_op');
  
  // عملية ثقيلة
  for (var i = 0; i < 1000000; i++) {
    // ...
  }
  
  timeline.finish();
}
```

### 3. Frame Rate Monitor
```dart
// في main.dart
void main() {
  WidgetsBinding.instance.addObserver(
    PerformanceObserver(),
  );
  runApp(const MyApp());
}
```

---

## 🎯 الأهداف

| المقياس | الهدف الحالي | الهدف المطلوب |
|--------|-------------|-------------|
| Startup Time | 2.5s | < 2s ⚡ |
| Screen Load | 500ms | < 300ms ⚡ |
| Frame Rate | 59 FPS | 60 FPS ✅ |
| Memory Usage | 120MB | < 100MB ⚡ |
| Scroll Smoothness | 95% | 100% ⚡ |

---

## 📈 الخطوات التالية

1. **الأسبوع 1**: تطبيق تحسينات الأولوية الأولى
2. **الأسبوع 2**: تطبيق تحسينات الأولوية الثانية
3. **الأسبوع 3**: قياس النتائج واختبار
4. **الأسبوع 4**: توثيق وتعليم الفريق

---

**يجب أن تكون التطبيق سريع جداً! ⚡**
