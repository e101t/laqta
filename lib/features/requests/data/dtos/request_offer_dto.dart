import 'package:cloud_firestore/cloud_firestore.dart';

class RequestOfferDto {
  final String id;
  final String requestId;
  final String photographerId;
  final double price;
  final String currency;
  final int deliveryDays;
  final Map<String, dynamic>? deliverables;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestOfferDto({
    required this.id,
    required this.requestId,
    required this.photographerId,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    this.deliverables,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequestOfferDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return RequestOfferDto(
      id: doc.id,
      requestId: _readString(data, 'requestId'),
      photographerId: _readString(data, 'photographerId'),
      price: _readDouble(data, 'price', fallback: 0),
      currency: _readString(data, 'currency', fallback: 'IQD'),
      deliveryDays: _readInt(data, 'deliveryDays', fallback: 0),
      deliverables: _readMap(data['deliverables']),
      notes: _readNullableString(data, 'notes'),
      status: _readString(data, 'status', fallback: 'submitted'),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  factory RequestOfferDto.fromJson(Map<String, dynamic> json) {
    return RequestOfferDto(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      photographerId: json['photographerId'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      deliveryDays: json['deliveryDays'] as int,
      deliverables: json['deliverables'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'photographerId': photographerId,
      'price': price,
      'currency': currency,
      'deliveryDays': deliveryDays,
      'deliverables': deliverables,
      'notes': notes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'photographerId': photographerId,
      'price': price,
      'currency': currency,
      'deliveryDays': deliveryDays,
      'deliverables': deliverables,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
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
