import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';

void main() {
  test('PortfolioImageDto resolves backend content URL from mediaId', () {
    final dto = PortfolioImageDto.fromMap({
      'mediaId': 'media-portfolio-1',
      'url':
          'https://firebasestorage.googleapis.com/v0/b/legacy/o/portfolio.jpg',
    });

    expect(dto.mediaId, 'media-portfolio-1');
    expect(dto.url, contains('/api/v1/media/media-portfolio-1/content'));
  });
}
