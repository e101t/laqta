import 'package:laqta/features/reels/data/dtos/comment_dto.dart';
import 'package:laqta/features/reels/data/dtos/reel_dto.dart';
import 'package:laqta/features/reels/domain/entities/comment_model.dart';
import 'package:laqta/features/reels/domain/entities/reel_model.dart';

class ReelsMapper {
  static ReelModel toReel(ReelDto dto) {
    return ReelModel(
      reelId: dto.id,
      photographerId: dto.photographerId,
      photographerName: dto.photographerName,
      photographerPhotoUrl: dto.photographerPhotoUrl,
      mediaId: dto.mediaId,
      videoUrl: dto.videoUrl,
      thumbnailUrl: dto.thumbnailUrl,
      caption: dto.caption,
      tags: dto.tags,
      views: dto.views,
      likes: dto.likes,
      comments: dto.comments,
      shares: dto.shares,
      createdAt: dto.createdAt,
      isVerified: dto.isVerified,
    );
  }

  static ReelDto toReelDto(ReelModel model) {
    return ReelDto(
      id: model.reelId,
      photographerId: model.photographerId,
      photographerName: model.photographerName,
      photographerPhotoUrl: model.photographerPhotoUrl,
      mediaId: model.mediaId,
      videoUrl: model.videoUrl,
      thumbnailUrl: model.thumbnailUrl,
      caption: model.caption,
      tags: model.tags,
      views: model.views,
      likes: model.likes,
      comments: model.comments,
      shares: model.shares,
      createdAt: model.createdAt,
      isVerified: model.isVerified,
    );
  }

  static CommentModel toComment(CommentDto dto) {
    return CommentModel(
      commentId: dto.id,
      reelId: dto.reelId,
      userId: dto.userId,
      userName: dto.userName,
      userPhotoUrl: dto.userPhotoUrl,
      text: dto.text,
      createdAt: dto.createdAt,
      likes: dto.likes,
    );
  }

  static CommentDto toCommentDto(CommentModel model) {
    return CommentDto(
      id: model.commentId,
      reelId: model.reelId,
      userId: model.userId,
      userName: model.userName,
      userPhotoUrl: model.userPhotoUrl,
      text: model.text,
      createdAt: model.createdAt,
      likes: model.likes,
    );
  }
}
