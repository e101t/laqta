import 'package:laqta/core/domain/result/result.dart';
import '../entities/portfolio.dart';
import '../entities/user_profile.dart';
import '../entities/user_profile_update.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getUserProfile({required String userId});

  Future<Result<void>> updateUserProfile({
    required String userId,
    required UserProfileUpdate update,
  });

  Future<Result<void>> saveBasicInfo({
    required String userId,
    required BasicInfoData data,
  });

  Future<Result<bool>> isUsernameAvailable(String usernameLower);

  Future<Result<String>> uploadProfilePhoto({
    required String userId,
    required String filePath,
  });

  Future<Result<Portfolio?>> getPortfolio({required String photographerId});

  Future<Result<void>> savePortfolio({
    required String photographerId,
    required List<PortfolioImage> images,
  });

  Future<Result<String>> uploadPortfolioImage({
    required String photographerId,
    required String filePath,
  });

  Future<Result<void>> deleteFileByUrl(String url);
}
