import 'package:luqta/core/domain/result/result.dart';
import '../entities/search_result_photographer.dart';
import '../repositories/search_repository.dart';

class SearchPhotographers {
  final SearchRepository _repository;

  const SearchPhotographers(this._repository);

  Future<Result<List<SearchResultPhotographer>>> call({required String query}) {
    return _repository.searchPhotographers(query: query);
  }
}
