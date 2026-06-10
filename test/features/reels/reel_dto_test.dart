import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/features/reels/data/dtos/reel_dto.dart';

void main() {
  test('fromJson resolves backend media content URL from mediaId', () {
    final dto = ReelDto.fromJson({
      'id': 'reel-1',
      'photographerId': 'photographer-1',
      'photographerName': 'Mariam',
      'mediaId': 'media-1',
      'caption': 'caption',
      'tags': ['wedding'],
      'views': 12,
      'likes': 4,
      'comments': 1,
      'shares': 2,
      'createdAt': '2026-04-16T12:00:00.000Z',
      'isVerified': false,
    });

    expect(dto.videoUrl, BackendConfig.mediaContentUrl('media-1'));
    expect(dto.mediaId, 'media-1');
    expect(dto.tags, ['wedding']);
  });
}
