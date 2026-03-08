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
