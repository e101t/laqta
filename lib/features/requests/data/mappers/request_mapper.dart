import 'package:laqta/features/requests/domain/entities/photo_request.dart';
import 'package:laqta/features/requests/domain/entities/request_deliverables.dart';
import '../dtos/request_dto.dart';

class RequestMapper {
  static PhotoRequest toDomain(RequestDto dto) {
    return PhotoRequest(
      id: dto.id,
      clientId: dto.clientId,
      type: dto.type,
      date: dto.date,
      time: dto.time,
      governorate: dto.governorate,
      address: dto.address,
      budgetMin: dto.budgetMin,
      budgetMax: dto.budgetMax,
      durationHours: dto.durationHours,
      style: dto.style,
      deliverables: _deliverablesFromMap(dto.deliverables),
      notes: dto.notes,
      referenceImageMediaIds: dto.referenceImageMediaIds,
      referenceImages: dto.referenceImages,
      status: dto.status,
      offersCount: dto.offersCount,
      selectedOfferId: dto.selectedOfferId,
      selectedPhotographerId: dto.selectedPhotographerId,
      expiresAt: dto.expiresAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      latitude: dto.latitude ?? dto.location?.lat,
      longitude: dto.longitude ?? dto.location?.lng,
      locationLabel: dto.locationLabel ?? dto.location?.label,
    );
  }

  static RequestDto toDto(PhotoRequest request) {
    return RequestDto(
      id: request.id,
      clientId: request.clientId,
      type: request.type,
      date: request.date,
      time: request.time,
      governorate: request.governorate,
      address: request.address,
      budgetMin: request.budgetMin,
      budgetMax: request.budgetMax,
      durationHours: request.durationHours,
      style: request.style,
      deliverables: _deliverablesToMap(request.deliverables),
      notes: request.notes,
      referenceImageMediaIds: request.referenceImageMediaIds,
      referenceImages: request.referenceImages,
      status: request.status,
      offersCount: request.offersCount,
      selectedOfferId: request.selectedOfferId,
      selectedPhotographerId: request.selectedPhotographerId,
      expiresAt: request.expiresAt,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      latitude: request.latitude,
      longitude: request.longitude,
      locationLabel: request.locationLabel,
      location: RequestLocationDto(
        lat: request.latitude,
        lng: request.longitude,
        label: request.locationLabel,
      ),
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
