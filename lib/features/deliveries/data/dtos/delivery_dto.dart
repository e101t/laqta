import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/services/backend_config.dart';

class DeliveryDto {
  final String id;
  final String bookingId;
  final String photographerId;
  final String customerId;
  final String status;
  final List<String> photoMediaIds;
  final List<String> videoMediaIds;
  final List<String> otherMediaIds;
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
    this.photoMediaIds = const [],
    this.videoMediaIds = const [],
    this.otherMediaIds = const [],
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
      photoMediaIds: _readStringList(data['photoMediaIds']),
      videoMediaIds: _readStringList(data['videoMediaIds']),
      otherMediaIds: _readStringList(data['otherMediaIds']),
      photoUrls: _resolveUrls(
        _readStringList(data['photoUrls']),
        _readStringList(data['photoMediaIds']),
      ),
      videoUrls: _resolveUrls(
        _readStringList(data['videoUrls']),
        _readStringList(data['videoMediaIds']),
      ),
      otherUrls: _resolveUrls(
        _readStringList(data['otherUrls']),
        _readStringList(data['otherMediaIds']),
      ),
      note: _readNullableString(data, 'note'),
      revisionNote: _readNullableString(data, 'revisionNote'),
      revisionCount: _readInt(data, 'revisionCount', fallback: 0),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    final photoMediaIds =
        (json['photoMediaIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final videoMediaIds =
        (json['videoMediaIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final otherMediaIds =
        (json['otherMediaIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    final photoUrls = _resolveUrls(
      (json['photoUrls'] as List<dynamic>?)?.whereType<String>().toList() ??
          const <String>[],
      photoMediaIds,
    );
    final videoUrls = _resolveUrls(
      (json['videoUrls'] as List<dynamic>?)?.whereType<String>().toList() ??
          const <String>[],
      videoMediaIds,
    );
    final otherUrls = _resolveUrls(
      (json['otherUrls'] as List<dynamic>?)?.whereType<String>().toList() ??
          const <String>[],
      otherMediaIds,
    );

    return DeliveryDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      photographerId: json['photographerId'] as String,
      customerId: json['customerId'] as String,
      status: json['status'] as String,
      photoMediaIds: photoMediaIds,
      videoMediaIds: videoMediaIds,
      otherMediaIds: otherMediaIds,
      photoUrls: photoUrls,
      videoUrls: videoUrls,
      otherUrls: otherUrls,
      note: json['note'] as String?,
      revisionNote: json['revisionNote'] as String?,
      revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'photographerId': photographerId,
      'customerId': customerId,
      'status': status,
      'photoMediaIds': photoMediaIds,
      'videoMediaIds': videoMediaIds,
      'otherMediaIds': otherMediaIds,
      if (photoMediaIds.isEmpty) 'photoUrls': photoUrls,
      if (videoMediaIds.isEmpty) 'videoUrls': videoUrls,
      if (otherMediaIds.isEmpty) 'otherUrls': otherUrls,
      'note': note,
      'revisionNote': revisionNote,
      'revisionCount': revisionCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'photographerId': photographerId,
      'customerId': customerId,
      'status': status,
      'photoMediaIds': photoMediaIds,
      'videoMediaIds': videoMediaIds,
      'otherMediaIds': otherMediaIds,
      'photoUrls': photoUrls,
      'videoUrls': videoUrls,
      'otherUrls': otherUrls,
      'note': note,
      'revisionNote': revisionNote,
      'revisionCount': revisionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'photoMediaIds': photoMediaIds,
      'videoMediaIds': videoMediaIds,
      'otherMediaIds': otherMediaIds,
      'note': note,
      'revisionNote': revisionNote,
      'revisionCount': revisionCount,
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

  static List<String> _resolveUrls(List<String> urls, List<String> mediaIds) {
    if (urls.isNotEmpty) {
      return urls;
    }
    if (mediaIds.isEmpty) {
      return const [];
    }
    return mediaIds.map(BackendConfig.mediaApiUrl).toList();
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
