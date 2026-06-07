import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/services/backend_config.dart';

void main() {
  test(
    'StoryModel.fromJson resolves backend media content URL from mediaId',
    () {
      final story = StoryModel.fromJson({
        'id': 'story-1',
        'userId': 'user-1',
        'photographerId': 'user-1',
        'photographerName': 'Mariam',
        'photographerPhotoUrl': 'https://example.com/avatar.jpg',
        'mediaId': 'media-1',
        'caption': 'new drop',
        'views': const [],
        'createdAt': '2026-04-16T12:00:00.000Z',
        'expiresAt': '2026-04-17T12:00:00.000Z',
        'isActive': true,
      });

      expect(story.storyId, 'story-1');
      expect(story.imageUrl, BackendConfig.mediaContentUrl('media-1'));
      expect(story.mediaId, 'media-1');
    },
  );
}
