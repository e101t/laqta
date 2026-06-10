import 'package:flutter/foundation.dart';
import 'package:laqta/features/search/data/datasources/firestore_search_remote_data_source.dart';
import 'package:laqta/features/search/data/datasources/search_remote_data_source.dart';
import 'package:laqta/features/search/data/repositories/search_repository_impl.dart';
import 'package:laqta/features/search/domain/repositories/search_repository.dart';
import 'package:laqta/features/search/domain/usecases/search_photographers.dart';

class SearchDependencies {
  static final SearchRemoteDataSource _remoteDataSource =
      FirestoreSearchRemoteDataSource();
  static final SearchRepository _defaultRepository = SearchRepositoryImpl(
    _remoteDataSource,
  );
  static SearchRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(SearchRepository? repository) {
    _repositoryOverride = repository;
  }

  static SearchRepository get _repository =>
      _repositoryOverride ?? _defaultRepository;

  static SearchPhotographers searchPhotographers() =>
      SearchPhotographers(_repository);
}
