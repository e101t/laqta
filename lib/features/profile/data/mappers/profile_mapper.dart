import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:luqta/features/profile/domain/entities/portfolio.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';

class ProfileMapper {
  static UserProfile toDomain(UserProfileDto dto) {
    return UserProfile(
      id: dto.id,
      role: dto.role,
      name: dto.name,
      username: dto.username,
      email: dto.email,
      phone: dto.phone,
      photoUrl: dto.photoUrl,
      governorate: dto.governorate,
      gender: dto.gender,
      age: dto.age,
      birthYear: dto.birthYear,
      lang: dto.lang,
      fcmToken: dto.fcmToken,
      profileCompleted: dto.profileCompleted,
      over18Confirmed: dto.over18Confirmed,
      interests: dto.interests,
      blockedUsers: dto.blockedUsers,
      lastSeen: dto.lastSeen,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static Portfolio toDomainPortfolio(PortfolioDto dto) {
    return Portfolio(
      id: dto.id,
      photographerId: dto.photographerId,
      images: dto.images
          .map(
            (img) => PortfolioImage(
              url: img.url,
              width: img.width,
              height: img.height,
              createdAt: img.createdAt,
            ),
          )
          .toList(),
    );
  }
}
