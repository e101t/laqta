import 'package:flutter/foundation.dart';
import 'package:laqta/features/requests/data/datasources/api_requests_remote_data_source.dart';
import 'package:laqta/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:laqta/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:laqta/features/requests/domain/repositories/requests_repository.dart';
import 'package:laqta/features/requests/domain/usecases/accept_offer.dart';
import 'package:laqta/features/requests/domain/usecases/create_offer.dart';
import 'package:laqta/features/requests/domain/usecases/create_request.dart';
import 'package:laqta/features/requests/domain/usecases/generate_offer_id.dart';
import 'package:laqta/features/requests/domain/usecases/generate_request_id.dart';
import 'package:laqta/features/requests/domain/usecases/get_my_offers.dart';
import 'package:laqta/features/requests/domain/usecases/get_my_requests.dart';
import 'package:laqta/features/requests/domain/usecases/get_offers_for_request.dart';
import 'package:laqta/features/requests/domain/usecases/get_open_requests.dart';
import 'package:laqta/features/requests/domain/usecases/get_request_by_id.dart';
import 'package:laqta/features/requests/domain/usecases/update_request.dart';
import 'package:laqta/features/requests/domain/usecases/upload_request_reference.dart';

class RequestsDependencies {
  static RequestsRemoteDataSource? _remoteDataSource;
  static RequestsRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(RequestsRepository? repository) {
    _repositoryOverride = repository;
  }

  static RequestsRemoteDataSource get _remote =>
      _remoteDataSource ??= ApiRequestsRemoteDataSource();

  static RequestsRepository get _repository =>
      _repositoryOverride ?? RequestsRepositoryImpl(_remote);

  static GetMyRequests getMyRequests() => GetMyRequests(_repository);

  static GetOpenRequests getOpenRequests() => GetOpenRequests(_repository);

  static GetRequestById getRequestById() => GetRequestById(_repository);

  static CreateRequest createRequest() => CreateRequest(_repository);

  static UpdateRequest updateRequest() => UpdateRequest(_repository);

  static GetOffersForRequest getOffersForRequest() =>
      GetOffersForRequest(_repository);

  static GetMyOffers getMyOffers() => GetMyOffers(_repository);

  static CreateOffer createOffer() => CreateOffer(_repository);

  static AcceptOffer acceptOffer() => AcceptOffer(_repository);

  static UploadRequestReference uploadRequestReference() =>
      UploadRequestReference(_repository);

  static GenerateRequestId generateRequestId() =>
      GenerateRequestId(_repository);

  static GenerateOfferId generateOfferId() => GenerateOfferId(_repository);
}
