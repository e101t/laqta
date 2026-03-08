import 'package:luqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:luqta/features/requests/domain/entities/request_offer.dart';
import '../dtos/request_offer_dto.dart';

class RequestOfferMapper {
  static RequestOffer toDomain(RequestOfferDto dto) {
    return RequestOffer(
      id: dto.id,
      requestId: dto.requestId,
      photographerId: dto.photographerId,
      price: dto.price,
      currency: dto.currency,
      deliveryDays: dto.deliveryDays,
      deliverables: _deliverablesFromMap(dto.deliverables),
      notes: dto.notes,
      status: dto.status,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static RequestOfferDto toDto(RequestOffer offer) {
    return RequestOfferDto(
      id: offer.id,
      requestId: offer.requestId,
      photographerId: offer.photographerId,
      price: offer.price,
      currency: offer.currency,
      deliveryDays: offer.deliveryDays,
      deliverables: _deliverablesToMap(offer.deliverables),
      notes: offer.notes,
      status: offer.status,
      createdAt: offer.createdAt,
      updatedAt: offer.updatedAt,
    );
  }

  static RequestDeliverables _deliverablesFromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const RequestDeliverables();
    }

    return RequestDeliverables(
      photosCount: _readNullableInt(map, 'photosCount'),
      videoMinutes: _readNullableInt(map, 'videoMinutes'),
      includesEditing: _readBool(map, 'includesEditing'),
      includesVideo: _readBool(map, 'includesVideo'),
      notes: _readNullableString(map, 'notes'),
    );
  }

  static Map<String, dynamic> _deliverablesToMap(
    RequestDeliverables deliverables,
  ) {
    return {
      'photosCount': deliverables.photosCount,
      'videoMinutes': deliverables.videoMinutes,
      'includesEditing': deliverables.includesEditing,
      'includesVideo': deliverables.includesVideo,
      'notes': deliverables.notes,
    };
  }

  static int? _readNullableInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool _readBool(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return false;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }
}
