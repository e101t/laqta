import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';
import 'package:laqta/features/search/domain/entities/search_result_photographer.dart';
import 'package:laqta/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  const SearchRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<SearchResultPhotographer>>> searchPhotographers({
    required String query,
  }) async {
    try {
      final queryLower = query.toLowerCase();
      final users = await _remoteDataSource.getPhotographerUsers();
      final photographers = await _remoteDataSource.getPhotographerDetails();
      final photographerMap = {
        for (final photographer in photographers) photographer.id: photographer,
      };

      final results = <SearchResultPhotographer>[];
      for (final user in users) {
        final photographer = photographerMap[user.id];
        if (photographer == null) {
          continue;
        }

        final matchesName = user.name.toLowerCase().contains(queryLower);
        final matchesSpecialties = photographer.specialties.any(
          (s) => s.toLowerCase().contains(queryLower),
        );
        final matchesGovernorates =
            photographer.governorates.any(
              (g) => g.toLowerCase().contains(queryLower),
            ) ||
            user.governorate.toLowerCase().contains(queryLower);

        if (matchesName || matchesSpecialties || matchesGovernorates) {
          results.add(
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
      }

      results.sort((a, b) => b.rating.compareTo(a.rating));
      return Result.success(results);
    } catch (error) {
      return Result.failure(Failure(message: error.toString()));
    }
  }
}
