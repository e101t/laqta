import 'package:luqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:luqta/features/profile/data/dtos/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileDto?> getUserProfile(String userId);

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates);

  Future<void> saveBasicInfo(String userId, Map<String, dynamic> data);

  Future<bool> isUsernameAvailable(String usernameLower);

  Future<String> uploadProfilePhoto(String userId, String filePath);

  Future<PortfolioDto?> getPortfolio(String photographerId);

  Future<void> savePortfolio(
    String photographerId,
    List<PortfolioImageDto> images,
  );

  Future<String> uploadPortfolioImage(String photographerId, String filePath);

  Future<void> deleteFileByUrl(String url);
}
