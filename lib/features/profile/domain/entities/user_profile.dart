class UserProfile {
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

  const UserProfile({
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
}
