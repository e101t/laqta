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

  factory DeliveryDto.fromJson(Map<String, dynamic> json) {
    final photoMediaIds =
        (json['photoMediaIds'] as List<dynamic>?)?.whereType<String>().toList() ??
        const <String>[];
    final videoMediaIds =
        (json['videoMediaIds'] as List<dynamic>?)?.whereType<String>().toList() ??
        const <String>[];
    final otherMediaIds =
        (json['otherMediaIds'] as List<dynamic>?)?.whereType<String>().toList() ??
        const <String>[];
    return DeliveryDto(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      photographerId: json['photographerId'] as String,
      customerId: json['customerId'] as String,
      status: json['status'] as String,
      photoMediaIds: photoMediaIds,
      videoMediaIds: videoMediaIds,
      otherMediaIds: otherMediaIds,
      photoUrls: _resolveUrls(
        (json['photoUrls'] as List<dynamic>?)?.whereType<String>().toList() ?? const <String>[],
        photoMediaIds,
      ),
      videoUrls: _resolveUrls(
        (json['videoUrls'] as List<dynamic>?)?.whereType<String>().toList() ?? const <String>[],
        videoMediaIds,
      ),
      otherUrls: _resolveUrls(
        (json['otherUrls'] as List<dynamic>?)?.whereType<String>().toList() ?? const <String>[],
        otherMediaIds,
      ),
      note: json['note'] as String?,
      revisionNote: json['revisionNote'] as String?,
      revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
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

  static List<String> _resolveUrls(List<String> urls, List<String> mediaIds) {
    if (urls.isNotEmpty) return urls;
    if (mediaIds.isEmpty) return const [];
    return mediaIds.map(BackendConfig.mediaApiUrl).toList();
  }
}
