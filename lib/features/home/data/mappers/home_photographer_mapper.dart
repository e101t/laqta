import 'package:luqta/core/models/photographer_profile.dart';
import '../../domain/entities/home_photographer.dart';

class HomePhotographerMapper {
  static HomePhotographer fromProfile(PhotographerProfile profile) {
    return HomePhotographer(
      id: profile.id,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      primaryGovernorate: profile.primaryGovernorate,
      specialties: profile.specialties,
      rating: profile.rating,
      reviewsCount: profile.reviewsCount,
      basePrice: profile.basePrice,
      username: profile.username,
      gender: profile.gender,
      age: profile.age,
      isTopRated: profile.isTopRated,
    );
  }
}
