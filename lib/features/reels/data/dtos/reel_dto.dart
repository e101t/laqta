import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/core/utils/legacy_data_compat.dart';

class ReelDto {
  final String id;
  final String photographerId;
  final String photographerName;
  final String? photographerPhotoUrl;
  final String? mediaId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final List<String> tags;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final bool isVerified;

  const ReelDto({
    required this.id,
    required this.photographerId,
    required this.photographerName,
    this.photographerPhotoUrl,
    this.mediaId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.caption,
    required this.tags,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.createdAt,
    required this.isVerified,
  });

  factory ReelDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ReelDto(
      id: doc.id,
      photographerId: _readString(data, 'photographerId'),
      photographerName: _readString(data, 'photographerName'),
      photographerPhotoUrl: _readNullableString(data, 'photographerPhotoUrl'),
      mediaId: _readNullableString(data, 'mediaId'),
      videoUrl: _resolveMediaUrl(data),
      thumbnailUrl: _readNullableString(data, 'thumbnailUrl'),
      caption: _readString(data, 'caption'),
      tags: _readStringList(data['tags']),
      views: _readInt(data, 'views'),
      likes: _readInt(data, 'likes'),
      comments: _readInt(data, 'comments'),
      shares: _readInt(data, 'shares'),
      createdAt: _readDateTime(data['createdAt']),
      isVerified: _readBool(data, 'isVerified'),
    );
  }

  factory ReelDto.fromJson(Map<String, dynamic> data) {
    return ReelDto(
      id: _readString(data, 'id'),
      photographerId: _readString(data, 'photographerId'),
      photographerName: _readString(data, 'photographerName'),
      photographerPhotoUrl: _readNullableString(data, 'photographerPhotoUrl'),
      mediaId: _readNullableString(data, 'mediaId'),
      videoUrl: _resolveMediaUrl(data),
      thumbnailUrl: _readNullableString(data, 'thumbnailUrl'),
      caption: _readString(data, 'caption'),
      tags: _readStringList(data['tags']),
      views: _readInt(data, 'views'),
      likes: _readInt(data, 'likes'),
      comments: _readInt(data, 'comments'),
      shares: _readInt(data, 'shares'),
      createdAt: _readDateTime(data['createdAt']),
      isVerified: _readBool(data, 'isVerified'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photographerId': photographerId,
      'photographerName': photographerName,
      'photographerPhotoUrl': photographerPhotoUrl,
      'mediaId': mediaId,
      if (mediaId == null || mediaId!.isEmpty) 'videoUrl': videoUrl,
      if (mediaId == null || mediaId!.isEmpty) 'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'tags': tags,
      'views': views,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVerified': isVerified,
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'mediaId': mediaId,
      'caption': caption,
      'tags': tags,
      'isVerified': isVerified,
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

  static String _resolveMediaUrl(Map<String, dynamic> data) {
    final mediaId = _readNullableString(data, 'mediaId');
    if (mediaId != null && mediaId.isNotEmpty) {
      return BackendConfig.mediaContentUrl(mediaId);
    }
    return _readString(data, 'videoUrl');
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
