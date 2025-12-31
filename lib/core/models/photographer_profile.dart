import 'package:luqta/core/models/photographer_model.dart';
import 'package:luqta/core/models/user_model.dart';

/// Aggregated view of a photographer that combines account + profile data.
class PhotographerProfile {
  final PhotographerModel photographer;
  final UserModel user;

  const PhotographerProfile({required this.photographer, required this.user});

  String get id => photographer.uid;
  String get displayName => user.name;
  String? get photoUrl => user.photoUrl;
  String get primaryGovernorate {
    if (user.governorate.isNotEmpty) return user.governorate;
    if (photographer.governorates.isNotEmpty) {
      return photographer.governorates.first;
    }
    return '';
  }

  String? get username => user.username;
  String? get gender => user.gender;
  int? get age => user.age;

  List<String> get specialties => photographer.specialties;
  double get rating => photographer.rate;
  int get reviewsCount => photographer.reviewsCount;
  double get basePrice => photographer.basePrice;
  bool get isTopRated => photographer.isTopRated;

  bool matchesGovernorate(String? governorate) {
    if (governorate == null || governorate.isEmpty) return true;
    final normalized = governorate.toLowerCase().trim();
    if (user.governorate.toLowerCase() == normalized) return true;
    return photographer.governorates.any(
      (item) => item.toLowerCase() == normalized,
    );
  }

  bool matchesSpecialty(String? specialty) {
    if (specialty == null || specialty.isEmpty) return true;
    final normalized = specialty.toLowerCase().trim();
    return photographer.specialties.any(
      (item) => item.toLowerCase() == normalized,
    );
  }

  bool matchesGender(String? gender) {
    if (gender == null || gender.isEmpty) return true;
    final normalized = gender.toLowerCase().trim();
    final userGender = user.gender?.toLowerCase().trim();
    return userGender == normalized;
  }

  bool matchesMinRating(double minRating) {
    if (minRating <= 0) return true;
    return photographer.rate >= minRating;
  }
}
