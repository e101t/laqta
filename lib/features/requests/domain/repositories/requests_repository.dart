import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart';
import '../entities/photo_request.dart';
import '../entities/request_offer.dart';

abstract class RequestsRepository {
  Future<Result<List<PhotoRequest>>> getMyRequests({required String clientId});

  Future<Result<List<PhotoRequest>>> getOpenRequests({
    String? governorate,
  });

  Future<Result<PhotoRequest>> getRequestById(String requestId);

  Future<Result<void>> createRequest(PhotoRequest request);

  Future<Result<void>> updateRequest({
    required String requestId,
    required Map<String, dynamic> updates,
  });

  Future<Result<List<RequestOffer>>> getOffersForRequest(String requestId);

  Future<Result<List<RequestOffer>>> getMyOffers({
    required String photographerId,
  });

  Future<Result<void>> createOffer(RequestOffer offer);

  Future<Result<void>> acceptOffer({
    required PhotoRequest request,
    required RequestOffer offer,
    required Booking booking,
  });

  Future<Result<String>> uploadReferenceImage({
    required String requestId,
    required String filePath,
  });

  String generateRequestId();
  String generateOfferId();
}
