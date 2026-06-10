import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/services/backend_config.dart';

class UserProfileDto {
  final String id;
  final String role;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? photoMediaId;
  final String? photoUrl;
  final String governorate;
  final String? gender;
  final int? age;
  final int? birthYear;
  final String lang;
  final String? fcmToken;
  final bool profileCompleted;
  final bool over18Confirmed;
  final List<String>? interests;
  final List<String> blockedUsers;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileDto({
    required this.id,
    required this.role,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.photoMediaId,
    this.photoUrl,
    required this.governorate,
    this.gender,
    this.age,
    this.birthYear,
    this.lang = 'ar',
    this.fcmToken,
    this.profileCompleted = false,
    this.over18Confirmed = false,
    this.interests,
    this.blockedUsers = const [],
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserProfileDto.fromMap(doc.id, data);
  }

  factory UserProfileDto.fromMap(String id, Map<String, dynamic> data) {
    return UserProfileDto(
      id: id,
      role: _readString(data, 'role', fallback: 'customer'),
      name: _readString(data, 'name'),
      username: _readNullableString(data, 'username'),
      email: _readNullableString(data, 'email'),
      phone: _readNullableString(data, 'phone'),
      photoMediaId: _readNullableString(data, 'photoMediaId'),
      photoUrl: _resolvePhotoUrl(data),
      governorate: _readString(data, 'governorate'),
      gender: _readNullableString(data, 'gender'),
      age: _readNullableInt(data, 'age'),
      birthYear: _readNullableInt(data, 'birthYear'),
      lang: _readString(data, 'lang', fallback: 'ar'),
      fcmToken: _readNullableString(data, 'fcmToken'),
      profileCompleted: _readBool(data, 'profileCompleted'),
      over18Confirmed: _readBool(data, 'over18Confirmed'),
      interests: _readStringListNullable(data['interests']),
      blockedUsers: _readStringList(data['blockedUsers']),
      lastSeen: _readNullableDateTime(data['lastSeen']),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
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

  static String? _resolvePhotoUrl(Map<String, dynamic> data) {
    final mediaId = _readNullableString(data, 'photoMediaId');
    if (mediaId != null && mediaId.isNotEmpty) {
      return BackendConfig.mediaContentUrl(mediaId);
    }

    return _readNullableString(data, 'photoUrl');
  }

  static int? _readNullableInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
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

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  static List<String>? _readStringListNullable(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }
}
