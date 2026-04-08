import 'package:cloud_functions/cloud_functions.dart'
    show FirebaseFunctionsException;
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/mappers/profile_mapper.dart';
import 'package:laqta/features/profile/domain/entities/portfolio.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:laqta/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserProfile>> getUserProfile({required String userId}) async {
    try {
      final dto = await _remoteDataSource.getUserProfile(userId);
      if (dto == null) {
        return Result.failure(const Failure(message: 'User not found'));
      }
      return Result.success(ProfileMapper.toDomain(dto));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to load user profile', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> updateUserProfile({
    required String userId,
    required UserProfileUpdate update,
  }) async {
    try {
      final updates = _buildUpdateMap(update);
      if (updates.isEmpty) {
        return Result.success(null);
      }
      await _remoteDataSource.updateUserProfile(userId, updates);
      return Result.success(null);
    } on FirebaseFunctionsException catch (e) {
      return Result.failure(
        Failure(
          message: e.message ?? 'Failed to update user profile',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update user profile', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> saveBasicInfo({
    required String userId,
    required BasicInfoData data,
  }) async {
    try {
      final normalized = data.username.trim().toLowerCase();
      await _remoteDataSource.saveBasicInfo(userId, {
        'role': data.role,
        'name': data.name,
        'username': normalized,
        'usernameLower': normalized,
        if (data.email != null) 'email': data.email,
        if (data.phone != null) 'phone': data.phone,
        'governorate': data.governorate,
        'gender': data.gender,
        'birthYear': data.birthYear,
        'age': data.age,
        'over18Confirmed': data.over18Confirmed,
        'profileCompleted': data.profileCompleted,
      });
      return Result.success(null);
    } on FirebaseFunctionsException catch (e) {
      return Result.failure(
        Failure(
          message: e.message ?? 'Failed to save basic info',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to save basic info', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String usernameLower) async {
    try {
      final available = await _remoteDataSource.isUsernameAvailable(
        usernameLower,
      );
      return Result.success(available);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to check username', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> uploadProfilePhoto({
    required String userId,
    required String filePath,
  }) async {
    try {
      final url = await _remoteDataSource.uploadProfilePhoto(userId, filePath);
      return Result.success(url);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to upload photo', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<Portfolio?>> getPortfolio({
    required String photographerId,
  }) async {
    try {
      final dto = await _remoteDataSource.getPortfolio(photographerId);
      if (dto == null) {
        return Result.success(null);
      }
      return Result.success(ProfileMapper.toDomainPortfolio(dto));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to load portfolio', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<void>> savePortfolio({
    required String photographerId,
    required List<PortfolioImage> images,
  }) async {
    try {
      final dtos = images
          .map(
            (img) => PortfolioImageDto(
              url: img.url,
              width: img.width,
              height: img.height,
              createdAt: img.createdAt,
            ),
          )
          .toList();
      await _remoteDataSource.savePortfolio(photographerId, dtos);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to save portfolio', code: e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> uploadPortfolioImage({
    required String photographerId,
    required String filePath,
  }) async {
    try {
      final url = await _remoteDataSource.uploadPortfolioImage(
        photographerId,
        filePath,
      );
      return Result.success(url);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Failed to upload portfolio image',
          code: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteFileByUrl(String url) async {
    try {
      await _remoteDataSource.deleteFileByUrl(url);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to delete file', code: e.toString()),
      );
    }
  }

  Map<String, dynamic> _buildUpdateMap(UserProfileUpdate update) {
    final updates = <String, dynamic>{};

    void setValue(String key, Object? value) {
      if (value != null) {
        updates[key] = value;
      }
    }

    setValue('role', update.role);
    setValue('name', update.name);
    setValue('username', update.username);
    if (update.username != null) {
      updates['usernameLower'] = update.username!.trim().toLowerCase();
    }
    setValue('email', update.email);
    setValue('phone', update.phone);
    setValue('photoUrl', update.photoUrl);
    setValue('governorate', update.governorate);
    setValue('gender', update.gender);
    setValue('age', update.age);
    setValue('birthYear', update.birthYear);
    setValue('profileCompleted', update.profileCompleted);
    setValue('over18Confirmed', update.over18Confirmed);

    return updates;
  }
}
