import 'package:laqta/features/booking/data/dtos/booking_dto.dart';
import '../dtos/request_dto.dart';
import '../dtos/request_offer_dto.dart';

abstract class RequestsRemoteDataSource {
  Future<List<RequestDto>> getMyRequests(String clientId);

  Future<List<RequestDto>> getOpenRequests({String? governorate});

  Future<RequestDto> getRequestById(String requestId);

  Future<void> createRequest(RequestDto request);

  Future<void> updateRequest(String requestId, Map<String, dynamic> updates);

  Future<List<RequestOfferDto>> getOffersForRequest(String requestId);

  Future<List<RequestOfferDto>> getMyOffers(String photographerId);

  Future<void> createOffer(RequestOfferDto offer);

  Future<void> acceptOffer({
    required RequestDto request,
    required RequestOfferDto offer,
    required BookingDto booking,
  });

  Future<String> uploadReferenceImage({
    required String requestId,
    required String filePath,
  });

  String generateRequestId();
  String generateOfferId();
}
