import 'package:laqta/features/downloads/data/datasources/downloads_remote_data_source.dart';
import 'package:laqta/features/downloads/data/datasources/firestore_downloads_remote_data_source.dart';
import 'package:laqta/features/downloads/data/repositories/download_repository_impl.dart';
import 'package:laqta/features/downloads/domain/usecases/download_usecases.dart';

class DownloadsDependencies {
  static final DownloadsRemoteDataSource _remoteDataSource =
      FirestoreDownloadsRemoteDataSource();

  static final DownloadRepository _repository = DownloadRepositoryImpl(
    _remoteDataSource,
  );

  static GenerateDownloadLinksUseCase generateDownloadLinks() =>
      GenerateDownloadLinksUseCase(repository: _repository);

  static ExtendDownloadLinkUseCase extendDownloadLink() =>
      ExtendDownloadLinkUseCase(repository: _repository);

  static GetDownloadLinksUseCase getDownloadLinks() =>
      GetDownloadLinksUseCase(repository: _repository);
}
