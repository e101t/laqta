import 'package:laqta/core/utils/firestore_parsers.dart';

class UserModel {
  final String uid;
  final String role;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
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

  UserModel({
    required this.uid,
    required this.role,
    required this.name,
    this.username,
    this.email,
    this.phone,
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

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      uid: id,
      role: readString(data, 'role', defaultValue: 'customer'),
      name: readString(data, 'name'),
      username: readNullableString(data, 'username'),
      email: readNullableString(data, 'email'),
      phone: readNullableString(data, 'phone'),
      photoUrl: readNullableString(data, 'photoUrl'),
      governorate: readString(data, 'governorate'),
      gender: readNullableString(data, 'gender'),
      age: readNullableInt(data, 'age'),
      birthYear: readNullableInt(data, 'birthYear'),
      lang: readString(data, 'lang', defaultValue: 'ar'),
      fcmToken: readNullableString(data, 'fcmToken'),
      profileCompleted: readBool(data, 'profileCompleted'),
      over18Confirmed: readBool(data, 'over18Confirmed'),
      interests: readStringListOrNull(data, 'interests'),
      blockedUsers: readStringList(data, 'blockedUsers'),
      lastSeen: readDate(data['lastSeen']),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'governorate': governorate,
      'gender': gender,
      'age': age,
      'birthYear': birthYear,
      'lang': lang,
      'fcmToken': fcmToken,
      'profileCompleted': profileCompleted,
      'over18Confirmed': over18Confirmed,
      'interests': interests,
      'blockedUsers': blockedUsers,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? role,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? photoUrl,
    String? governorate,
    String? gender,
    int? age,
    int? birthYear,
    String? lang,
    String? fcmToken,
    bool? profileCompleted,
    bool? over18Confirmed,
    List<String>? interests,
    List<String>? blockedUsers,
    DateTime? lastSeen,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      role: role ?? this.role,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      governorate: governorate ?? this.governorate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      birthYear: birthYear ?? this.birthYear,
      lang: lang ?? this.lang,
      fcmToken: fcmToken ?? this.fcmToken,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      over18Confirmed: over18Confirmed ?? this.over18Confirmed,
      interests: interests ?? this.interests,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
