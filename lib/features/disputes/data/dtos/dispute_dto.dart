import 'package:cloud_firestore/cloud_firestore.dart';

class DisputeDto {
  final String id;
  final String bookingId;
  final String? requestId;
  final String customerId;
  final String photographerId;
  final String openedBy;
  final String reason;
  final String details;
  final List<String> evidenceUrls;
  final String status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final String? decidedBy;

  const DisputeDto({
    required this.id,
    required this.bookingId,
    this.requestId,
    required this.customerId,
    required this.photographerId,
    required this.openedBy,
    required this.reason,
    required this.details,
    required this.evidenceUrls,
    required this.status,
    this.resolution,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.decidedBy,
  });

  factory DisputeDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return DisputeDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      requestId: _readNullableString(data, 'requestId'),
      customerId: _readString(data, 'customerId'),
      photographerId: _readString(data, 'photographerId'),
      openedBy: _readString(data, 'openedBy'),
      reason: _readString(data, 'reason'),
      details: _readString(data, 'details'),
      evidenceUrls: _readStringList(data['evidenceUrls']),
      status: _readString(data, 'status', fallback: 'open'),
      resolution: _readNullableString(data, 'resolution'),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
      closedAt: _readNullableDateTime(data['closedAt']),
      decidedBy: _readNullableString(data, 'decidedBy'),
    );
  }

  factory DisputeDto.fromJson(Map<String, dynamic> json) {
    return DisputeDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      requestId: json['requestId'] as String?,
      customerId: json['customerId'] as String,
      photographerId: json['photographerId'] as String,
      openedBy: json['openedBy'] as String,
      reason: json['reason'] as String,
      details: json['details'] as String,
      evidenceUrls: (json['evidenceUrls'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
      resolution: json['resolution'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      decidedBy: json['decidedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'requestId': requestId,
      'customerId': customerId,
      'photographerId': photographerId,
      'openedBy': openedBy,
      'reason': reason,
      'details': details,
      'evidenceUrls': evidenceUrls,
      'status': status,
      'resolution': resolution,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'decidedBy': decidedBy,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'requestId': requestId,
      'customerId': customerId,
      'photographerId': photographerId,
      'openedBy': openedBy,
      'reason': reason,
      'details': details,
      'evidenceUrls': evidenceUrls,
      'status': status,
      'resolution': resolution,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'decidedBy': decidedBy,
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

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
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
