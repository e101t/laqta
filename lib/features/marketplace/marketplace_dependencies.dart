import 'package:laqta/core/services/backend_session_service.dart';
import 'package:laqta/features/marketplace/data/datasources/api_marketplace_remote_data_source.dart';
import 'package:laqta/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:laqta/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:laqta/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceDependencies {
  MarketplaceDependencies._();

  static final BackendSessionService _sessionService = BackendSessionService();
  static final MarketplaceRemoteDataSource _remoteDataSource =
      ApiMarketplaceRemoteDataSource();
  static final MarketplaceRepository _repository = MarketplaceRepositoryImpl(
    _remoteDataSource,
  );

  static MarketplaceRepository get repository => _repository;
  static BackendSessionService get sessionService => _sessionService;
}
