import 'package:laqta/core/models/portfolio_model.dart' as core;
import 'package:laqta/core/models/user_model.dart' as core;
import 'package:laqta/features/profile/domain/entities/portfolio.dart'
    as domain;
import 'package:laqta/features/profile/domain/entities/user_profile.dart';

class ProfilePresentationMapper {
  static core.UserModel toUserModel(UserProfile profile) {
    return core.UserModel(
      uid: profile.id,
      role: profile.role,
      name: profile.name,
      username: profile.username,
      email: profile.email,
      phone: profile.phone,
      photoUrl: profile.photoUrl,
      governorate: profile.governorate,
      gender: profile.gender,
      age: profile.age,
      birthYear: profile.birthYear,
      lang: profile.lang,
      fcmToken: profile.fcmToken,
      profileCompleted: profile.profileCompleted,
      over18Confirmed: profile.over18Confirmed,
      interests: profile.interests,
      blockedUsers: profile.blockedUsers,
      lastSeen: profile.lastSeen,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  static core.PortfolioModel toPortfolioModel(domain.Portfolio portfolio) {
    return core.PortfolioModel(
      id: portfolio.id,
      photographerId: portfolio.photographerId,
      images: portfolio.images
          .map(
            (img) => core.PortfolioImage(
              url: img.url,
              width: img.width,
              height: img.height,
              createdAt: img.createdAt,
            ),
          )
          .toList(),
    );
  }

  static List<core.PortfolioImage> toPortfolioImages(
    List<domain.PortfolioImage> images,
  ) {
    return images
        .map(
          (img) => core.PortfolioImage(
            url: img.url,
            width: img.width,
            height: img.height,
            createdAt: img.createdAt,
          ),
        )
        .toList();
  }

  static List<domain.PortfolioImage> toDomainImages(
    List<core.PortfolioImage> images,
  ) {
    return images
        .map(
          (img) => domain.PortfolioImage(
            url: img.url,
            width: img.width,
            height: img.height,
            createdAt: img.createdAt,
          ),
        )
        .toList();
  }
}
