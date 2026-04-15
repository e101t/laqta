import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/services/backend_media_service.dart';

void main() {
  group('BackendMediaService.extractMediaId', () {
    test('extracts media id from private backend media URLs', () {
      expect(
        BackendMediaService.extractMediaId(
          'https://api.laqta.cloud/api/v1/media/abc-123',
        ),
        'abc-123',
      );
    });

    test('extracts media id from public content URLs', () {
      expect(
        BackendMediaService.extractMediaId(
          'https://api.laqta.cloud/api/v1/media/xyz-789/content',
        ),
        'xyz-789',
      );
    });

    test('returns null for non-backend URLs', () {
      expect(
        BackendMediaService.extractMediaId(
          'https://firebasestorage.googleapis.com/v0/b/example/o/file.jpg',
        ),
        isNull,
      );
    });
  });
}
