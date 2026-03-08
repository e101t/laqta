import 'package:luqta/core/domain/failures/failure.dart';
import 'package:luqta/core/domain/result/result.dart';
import 'package:luqta/features/booking/data/mappers/booking_mapper.dart';
import 'package:luqta/features/booking/domain/entities/booking.dart';
import 'package:luqta/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:luqta/features/requests/data/mappers/request_mapper.dart';
import 'package:luqta/features/requests/data/mappers/request_offer_mapper.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/domain/entities/request_offer.dart';
import 'package:luqta/features/requests/domain/repositories/requests_repository.dart';

class RequestsRepositoryImpl implements RequestsRepository {
  final RequestsRemoteDataSource _remoteDataSource;

  const RequestsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<PhotoRequest>>> getMyRequests({
    required String clientId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getMyRequests(clientId);
      final requests = dtos.map(RequestMapper.toDomain).toList();
      return Result.success(requests);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load requests'));
    }
  }

  @override
  Future<Result<List<PhotoRequest>>> getOpenRequests({
    String? governorate,
  }) async {
    try {
      final dtos = await _remoteDataSource.getOpenRequests(
        governorate: governorate,
      );
      final requests = dtos.map(RequestMapper.toDomain).toList();
      return Result.success(requests);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load open requests'),
      );
    }
  }

  @override
  Future<Result<PhotoRequest>> getRequestById(String requestId) async {
    try {
      final dto = await _remoteDataSource.getRequestById(requestId);
      return Result.success(RequestMapper.toDomain(dto));
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load request'));
    }
  }

  @override
  Future<Result<void>> createRequest(PhotoRequest request) async {
    try {
      final dto = RequestMapper.toDto(request);
      await _remoteDataSource.createRequest(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create request'));
    }
  }

  @override
  Future<Result<void>> updateRequest({
    required String requestId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _remoteDataSource.updateRequest(requestId, updates);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to update request'));
    }
  }

  @override
  Future<Result<List<RequestOffer>>> getOffersForRequest(
    String requestId,
  ) async {
    try {
      final dtos = await _remoteDataSource.getOffersForRequest(requestId);
      final offers = dtos.map(RequestOfferMapper.toDomain).toList();
      return Result.success(offers);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load offers'));
    }
  }

  @override
  Future<Result<List<RequestOffer>>> getMyOffers({
    required String photographerId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getMyOffers(photographerId);
      final offers = dtos.map(RequestOfferMapper.toDomain).toList();
      return Result.success(offers);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load offers'));
    }
  }

  @override
  Future<Result<void>> createOffer(RequestOffer offer) async {
    try {
      final dto = RequestOfferMapper.toDto(offer);
      await _remoteDataSource.createOffer(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to send offer'));
    }
  }

  @override
  Future<Result<void>> acceptOffer({
    required PhotoRequest request,
    required RequestOffer offer,
    required Booking booking,
  }) async {
    try {
      final requestDto = RequestMapper.toDto(request);
      final offerDto = RequestOfferMapper.toDto(offer);
      final bookingDto = BookingMapper.toDto(booking);
      await _remoteDataSource.acceptOffer(
        request: requestDto,
        offer: offerDto,
        booking: bookingDto,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to accept offer'));
    }
  }

  @override
  Future<Result<String>> uploadReferenceImage({
    required String requestId,
    required String filePath,
  }) async {
    try {
      final url = await _remoteDataSource.uploadReferenceImage(
        requestId: requestId,
        filePath: filePath,
      );
      return Result.success(url);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to upload image'));
    }
  }

  @override
  String generateRequestId() => _remoteDataSource.generateRequestId();

  @override
  String generateOfferId() => _remoteDataSource.generateOfferId();
}
