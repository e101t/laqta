import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';

void main() {
  test('UserProfileDto resolves backend photo URL from photoMediaId', () {
    final dto = UserProfileDto.fromMap('user-1', {
      'role': 'customer',
      'name': 'Mariam',
      'photoMediaId': 'media-123',
      'photoUrl':
          'https://firebasestorage.googleapis.com/v0/b/legacy/o/avatar.jpg',
      'governorate': 'Baghdad',
      'createdAt': DateTime(2026, 4, 17, 12),
      'updatedAt': DateTime(2026, 4, 17, 12),
    });

    expect(dto.photoMediaId, 'media-123');
    expect(dto.photoUrl, contains('/api/v1/media/media-123/content'));
  });
}
