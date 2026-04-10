import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';
import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/search/domain/entities/search_result_photographer.dart';
import 'package:laqta/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final Duration _cacheDuration;
  final DateTime Function() _now;
  List<SearchResultPhotographer>? _cachedPhotographers;
  DateTime? _cachedAt;

  SearchRepositoryImpl(
    this._remoteDataSource, {
    Duration cacheDuration = const Duration(minutes: 3),
    DateTime Function()? now,
  }) : _cacheDuration = cacheDuration,
       _now = now ?? DateTime.now;

  @override
  Future<Result<List<SearchResultPhotographer>>> searchPhotographers({
    required String query,
  }) async {
    try {
      final queryLower = query.trim().toLowerCase();
      final photographers = await _loadPhotographersIndex();
      final results = photographers.where((photographer) {
        if (queryLower.isEmpty) return true;
        final matchesName = photographer.name.toLowerCase().contains(
          queryLower,
        );
        final matchesSpecialties = photographer.specialties.any(
          (s) => s.toLowerCase().contains(queryLower),
        );
        final matchesGovernorate = photographer.governorate
            .toLowerCase()
            .contains(queryLower);
        final matchesUsername = (photographer.username ?? '')
            .toLowerCase()
            .contains(queryLower);
        return matchesName ||
            matchesSpecialties ||
            matchesGovernorate ||
            matchesUsername;
      }).toList();
      results.sort((a, b) => b.rating.compareTo(a.rating));
      return Result.success(results);
    } catch (error) {
      return Result.failure(Failure(message: error.toString()));
    }
  }

  Future<List<SearchResultPhotographer>> _loadPhotographersIndex() async {
    final cached = _cachedPhotographers;
    final cachedAt = _cachedAt;
    final now = _now();
    if (cached != null &&
        cachedAt != null &&
        now.difference(cachedAt) <= _cacheDuration) {
      return cached;
    }

    final results = await Future.wait([
      _remoteDataSource.getPhotographerUsers(),
      _remoteDataSource.getPhotographerDetails(),
    ]);
    final users = results[0] as List<UserProfileDto>;
    final photographerDetails = results[1] as List<PhotographerDetailsDto>;
    final photographerMap = {
      for (final photographer in photographerDetails)
        photographer.id: photographer,
    };

    final merged = <SearchResultPhotographer>[];
    for (final user in users) {
      final photographer = photographerMap[user.id];
      if (photographer == null) {
        continue;
      }

      merged.add(
        SearchResultPhotographer(
          id: user.id,
          name: user.name,
          image: user.photoUrl ?? '',
          specialties: photographer.specialties,
          rating: photographer.rate,
          reviewCount: photographer.reviewsCount,
          startingPrice: photographer.basePrice,
          governorate: user.governorate,
          username: user.username,
          gender: user.gender,
          age: user.age,
        ),
      );
    }

    merged.sort((a, b) {
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.reviewCount.compareTo(a.reviewCount);
    });

    _cachedPhotographers = List<SearchResultPhotographer>.unmodifiable(merged);
    _cachedAt = now;
    return _cachedPhotographers!;
  }
}
