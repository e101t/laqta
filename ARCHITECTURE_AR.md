# 🏗️ دليل البنية المعمارية - LAQTA

## Clean Architecture

LAQTA يتبع **Clean Architecture** مع تقسيم حسب Features.

## الطبقات الثلاث

```
Presentation Layer (UI)
        ↓ (depends on)
Domain Layer (Business Logic)
        ↓ (depends on)
Data Layer (Repositories & Data Sources)
```

## هيكل Feature

كل feature منفصل ومكتفي ذاتياً:

```
features/booking/
├── data/
│   ├── datasources/
│   │   ├── booking_local_data_source.dart
│   │   └── booking_remote_data_source.dart
│   ├── dtos/
│   │   └── booking_dto.dart
│   ├── mappers/
│   │   └── booking_mapper.dart
│   └── repositories/
│       └── booking_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── booking_entity.dart
│   ├── repositories/
│   │   └── booking_repository.dart
│   └── usecases/
│       ├── create_booking.dart
│       ├── get_booking.dart
│       └── cancel_booking.dart
├── presentation/
│   ├── screens/
│   │   ├── booking_list_screen.dart
│   │   └── booking_detail_screen.dart
│   ├── widgets/
│   │   ├── booking_card.dart
│   │   └── booking_status_badge.dart
│   ├── providers/
│   │   └── booking_provider.dart
│   └── mappers/
│       └── booking_presentation_mapper.dart
└── booking_dependencies.dart
```

## التدفق الرئيسي

### 1. Presentation Layer
```dart
// Screen يحتاج بيانات
class BookingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        // عرض البيانات
        return ListView(
          children: provider.bookings
              .map((b) => BookingCard(booking: b))
              .toList(),
        );
      },
    );
  }
}
```

### 2. Provider (State Management)
```dart
class BookingProvider extends ChangeNotifier {
  final GetBookingsUseCase _getBookings;
  
  List<Booking> _bookings = [];
  
  Future<void> loadBookings() async {
    final result = await _getBookings.call();
    _bookings = result.fold(
      (failure) => [],
      (bookings) => bookings,
    );
    notifyListeners();
  }
}
```

### 3. Domain Layer (Use Cases)
```dart
class GetBookingsUseCase {
  final BookingRepository repository;
  
  Future<Result<List<Booking>>> call() {
    return repository.getBookings();
  }
}
```

### 4. Data Layer (Repository)
```dart
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final BookingLocalDataSource localDataSource;
  
  @override
  Future<Result<List<Booking>>> getBookings() async {
    try {
      final dtos = await remoteDataSource.getBookings();
      final bookings = dtos.map((dto) => dto.toEntity()).toList();
      await localDataSource.cacheBookings(bookings);
      return Result.success(bookings);
    } catch (e) {
      return Result.failure(Failure.networkFailure());
    }
  }
}
```

### 5. Remote Data Source
```dart
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final BackendApiClient apiClient;
  
  @override
  Future<List<BookingDto>> getBookings() async {
    final response = await apiClient.get('/bookings');
    return (response as List)
        .map((item) => BookingDto.fromJson(item))
        .toList();
  }
}
```

## الـ Dependencies Injection

```dart
// booking_dependencies.dart
class BookingDependencies {
  static BookingRemoteDataSource _getRemoteDataSource() {
    return BookingRemoteDataSourceImpl(BackendApiClient.instance);
  }

  static BookingLocalDataSource _getLocalDataSource() {
    return BookingLocalDataSourceImpl();
  }

  static BookingRepository _getRepository() {
    return BookingRepositoryImpl(
      remoteDataSource: _getRemoteDataSource(),
      localDataSource: _getLocalDataSource(),
    );
  }

  static GetBookingsUseCase getBookings() {
    return GetBookingsUseCase(_getRepository());
  }

  static CreateBookingUseCase createBooking() {
    return CreateBookingUseCase(_getRepository());
  }
}
```

## نمط Result (لمعالجة الأخطاء)

```dart
abstract class Result<T> {
  factory Result.success(T value) = _Success<T>;
  factory Result.failure(Failure failure) = _Failure<T>;

  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  );

  T? get valueOrNull;
}

class _Success<T> implements Result<T> {
  final T value;
  _Success(this.value);

  @override
  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return onSuccess(value);
  }

  @override
  T? get valueOrNull => value;
}
```

## نمط Entity-DTO-Model

### Entity (Domain)
```dart
class Booking {
  final String id;
  final String photographerId;
  final DateTime date;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.photographerId,
    required this.date,
    required this.status,
  });
}
```

### DTO (Data)
```dart
class BookingDto {
  final String id;
  final String photographerId;
  final String date;
  final String status;

  BookingDto({
    required this.id,
    required this.photographerId,
    required this.date,
    required this.status,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json['id'],
      photographerId: json['photographer_id'],
      date: json['date'],
      status: json['status'],
    );
  }

  Booking toEntity() {
    return Booking(
      id: id,
      photographerId: photographerId,
      date: DateTime.parse(date),
      status: BookingStatus.values.byName(status),
    );
  }
}
```

### Model (Presentation)
```dart
class BookingModel {
  final String id;
  final String photographerName;
  final DateTime date;
  final String displayStatus;

  BookingModel.fromEntity(Booking entity)
      : id = entity.id,
        photographerName = '', // قد يكون مأخوذ من cache
        date = entity.date,
        displayStatus = entity.status.name;
}
```

## Core Services

### تخدم جميع Features:

```
core/
├── services/
│   ├── backend_api_client.dart       # API communication
│   ├── backend_media_service.dart    # Media uploads
│   ├── notification_service.dart     # Notifications
│   └── storage_service.dart          # Secure storage
├── network/
│   ├── connectivity_service.dart     # Connection checks
│   └── cache_interceptor.dart        # Response caching
├── theme/
│   ├── laqta_theme.dart
│   ├── laqta_tokens.dart
│   └── laqta_typography.dart
├── widgets/
│   ├── app_buttons.dart
│   ├── app_text_field.dart
│   └── loading_widgets.dart
└── utils/
    ├── validators.dart
    ├── governorate_utils.dart
    └── image_provider.dart
```

## Best Practices

### ✅ Do's
- ✅ Feature مستقل تماماً
- ✅ استخدم interfaces للـ repositories
- ✅ Implement Result pattern
- ✅ Inject dependencies
- ✅ اكتب tests مع الكود

### ❌ Don'ts
- ❌ Cross-feature dependencies
- ❌ Context passing عبر layers
- ❌ Direct API calls من screens
- ❌ Global state
- ❌ Skipping error handling

---

**Keep Architecture Clean! 🏛️**
