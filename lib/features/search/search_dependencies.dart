import 'package:luqta/features/search/data/datasources/firestore_search_remote_data_source.dart';
import 'package:luqta/features/search/data/datasources/search_remote_data_source.dart';
import 'package:luqta/features/search/data/repositories/search_repository_impl.dart';
import 'package:luqta/features/search/domain/repositories/search_repository.dart';
import 'package:luqta/features/search/domain/usecases/search_photographers.dart';

class SearchDependencies {
  static final SearchRemoteDataSource _remoteDataSource =
      FirestoreSearchRemoteDataSource();
  static final SearchRepository _repository = SearchRepositoryImpl(
    _remoteDataSource,
  );

  static SearchPhotographers searchPhotographers() =>
      SearchPhotographers(_repository);
}
