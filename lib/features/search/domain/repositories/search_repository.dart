import 'package:luqta/core/domain/result/result.dart';
import '../entities/search_result_photographer.dart';

abstract class SearchRepository {
  Future<Result<List<SearchResultPhotographer>>> searchPhotographers({
    required String query,
  });
}
