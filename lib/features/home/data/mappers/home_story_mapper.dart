import 'package:luqta/core/models/story_model.dart';
import '../../domain/entities/home_story.dart';

class HomeStoryMapper {
  static HomeStory fromModel(StoryModel model) {
    return HomeStory(
      storyId: model.storyId,
      photographerId: model.photographerId,
      photographerName: model.photographerName,
      photographerPhotoUrl: model.photographerPhotoUrl,
      imageUrl: model.imageUrl,
      caption: model.caption,
      createdAt: model.createdAt,
      expiresAt: model.expiresAt,
      views: model.views
          .map(
            (view) => HomeStoryView(
              userId: view.userId,
              userName: view.userName,
              viewedAt: view.viewedAt,
            ),
          )
          .toList(),
      isActive: model.isActive,
    );
  }
}
