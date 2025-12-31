class UserProfileUpdate {
  final String? role;
  final String? name;
  final String? username;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? governorate;
  final String? gender;
  final int? age;
  final int? birthYear;
  final bool? profileCompleted;
  final bool? over18Confirmed;

  const UserProfileUpdate({
    this.role,
    this.name,
    this.username,
    this.email,
    this.phone,
    this.photoUrl,
    this.governorate,
    this.gender,
    this.age,
    this.birthYear,
    this.profileCompleted,
    this.over18Confirmed,
  });
}

class BasicInfoData {
  final String role;
  final String name;
  final String username;
  final String governorate;
  final String? gender;
  final int? birthYear;
  final int? age;
  final bool over18Confirmed;
  final bool profileCompleted;

  const BasicInfoData({
    required this.role,
    required this.name,
    required this.username,
    required this.governorate,
    this.gender,
    this.birthYear,
    this.age,
    this.over18Confirmed = false,
    this.profileCompleted = true,
  });
}
