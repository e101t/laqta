import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryDto {
  final String id;
  final String bookingId;
  final String photographerId;
  final String customerId;
  final String status;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> otherUrls;
  final String? note;
  final String? revisionNote;
  final int revisionCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryDto({
    required this.id,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    required this.status,
    required this.photoUrls,
    required this.videoUrls,
    required this.otherUrls,
    this.note,
    this.revisionNote,
    required this.revisionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return DeliveryDto(
      id: doc.id,
      bookingId: _readString(data, 'bookingId'),
      photographerId: _readString(data, 'photographerId'),
      customerId: _readString(data, 'customerId'),
      status: _readString(data, 'status', fallback: 'submitted'),
      photoUrls: _readStringList(data['photoUrls']),
      videoUrls: _readStringList(data['videoUrls']),
      otherUrls: _readStringList(data['otherUrls']),
      note: _readNullableString(data, 'note'),
      revisionNote: _readNullableString(data, 'revisionNote'),
      revisionCount: _readInt(data, 'revisionCount', fallback: 0),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'photographerId': photographerId,
      'customerId': customerId,
      'status': status,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'otherUrls': otherUrls,
      'note': note,
      'revisionNote': revisionNote,
      'revisionCount': revisionCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
}
