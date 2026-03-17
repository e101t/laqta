import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laqta/core/utils/firestore_parsers.dart';

class UserModel {
  final String uid;
  final String role; // customer, photographer, admin
  final String name;
  final String? username; // NEW: Unique username
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String governorate;
  final String? gender; // NEW: male, female
  final int? age; // NEW: User's age
  final int? birthYear; // NEW: Birth year
  final String lang; // ar, en
  final String? fcmToken;
  final bool profileCompleted;
  final bool over18Confirmed; // NEW: Confirmation for 18+ age
  final List<String>? interests; // For customers
  final List<String> blockedUsers; // Users blocked by this user
  final DateTime? lastSeen; // Timestamp for online status
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

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    return UserModel(
      uid: doc.id,
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

  Map<String, dynamic> toFirestore() {
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
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
