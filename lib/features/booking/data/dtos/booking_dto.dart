import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDto {
  final String id;
  final String customerId;
  final String photographerId;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final int duration; // minutes
  final String type; // specialty
  final double price;
  final String currency;
  final String status; // pending, confirmed, rejected, done, canceled
  final BookingPaymentDto payment;
  final BookingLocationDto location;
  final String? notes;
  final String? chatId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingDto({
    required this.id,
    required this.customerId,
    required this.photographerId,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.price,
    required this.currency,
    required this.status,
    required this.payment,
    required this.location,
    this.notes,
    this.chatId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final paymentMap = _readMap(data['payment']);
    final locationMap = _readMap(data['location']);

    return BookingDto(
      id: doc.id,
      customerId: _readString(data, 'customerId'),
      photographerId: _readString(data, 'photographerId'),
      date: _readString(data, 'date'),
      time: _readString(data, 'time'),
      duration: _readInt(data, 'duration', fallback: 60),
      type: _readString(data, 'type'),
      price: _readDouble(data, 'price', fallback: 0),
      currency: _readString(data, 'currency', fallback: 'IQD'),
      status: _readString(data, 'status', fallback: 'pending'),
      payment: BookingPaymentDto.fromMap(paymentMap),
      location: BookingLocationDto.fromMap(locationMap),
      notes: _readNullableString(data, 'notes'),
      chatId: _readNullableString(data, 'chatId'),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'date': date,
      'time': time,
      'duration': duration,
      'type': type,
      'price': price,
      'currency': currency,
      'status': status,
      'payment': payment.toMap(),
      'location': location.toMap(),
      'notes': notes,
      'chatId': chatId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }

  static int _readInt(
    Map<String, dynamic> data,
    String key, {
    int fallback = 0,
  }) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double _readDouble(
    Map<String, dynamic> data,
    String key, {
    double fallback = 0,
  }) {
    final value = data[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double? _readNullableDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}

class BookingPaymentDto {
  final String status;
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  const BookingPaymentDto({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });

  factory BookingPaymentDto.fromMap(Map<String, dynamic> map) {
    return BookingPaymentDto(
      status: BookingDto._readString(map, 'status', fallback: 'pending'),
      intentId: BookingDto._readNullableString(map, 'intentId'),
      amount: BookingDto._readNullableDouble(map, 'amount'),
      paidAt: _readNullableDateTime(map['paidAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'intentId': intentId,
      'amount': amount,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class BookingLocationDto {
  final double? lat;
  final double? lng;
  final String? text;

  const BookingLocationDto({this.lat, this.lng, this.text});

  factory BookingLocationDto.fromMap(Map<String, dynamic> map) {
    return BookingLocationDto(
      lat: BookingDto._readNullableDouble(map, 'lat'),
      lng: BookingDto._readNullableDouble(map, 'lng'),
      text: BookingDto._readNullableString(map, 'text'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'text': text};
  }
}
