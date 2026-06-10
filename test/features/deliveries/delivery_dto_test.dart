import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/features/deliveries/data/dtos/delivery_dto.dart';

void main() {
  test(
    'fromJson resolves backend media URLs when backend payload omits URL arrays',
    () {
      final dto = DeliveryDto.fromJson({
        'id': 'booking-1',
        'bookingId': 'booking-1',
        'photographerId': 'photographer-1',
        'customerId': 'customer-1',
        'status': 'submitted',
        'photoMediaIds': ['media-photo-1'],
        'videoMediaIds': ['media-video-1'],
        'otherMediaIds': ['media-other-1'],
        'note': 'edited files',
        'revisionNote': null,
        'revisionCount': 0,
        'createdAt': '2026-04-16T10:00:00.000Z',
        'updatedAt': '2026-04-16T10:00:00.000Z',
      });

      expect(dto.photoUrls, [BackendConfig.mediaApiUrl('media-photo-1')]);
      expect(dto.videoUrls, [BackendConfig.mediaApiUrl('media-video-1')]);
      expect(dto.otherUrls, [BackendConfig.mediaApiUrl('media-other-1')]);
    },
  );
}
