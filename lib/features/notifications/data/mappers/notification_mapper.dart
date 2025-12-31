import 'package:luqta/features/notifications/data/dtos/notification_dto.dart';
import 'package:luqta/features/notifications/domain/entities/notification_model.dart';

class NotificationMapper {
  static NotificationModel toDomain(NotificationDto dto) {
    return NotificationModel(
      notificationId: dto.id,
      userId: dto.userId,
      title: dto.title,
      body: dto.body,
      type: dto.type,
      data: dto.data,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      imageUrl: dto.imageUrl,
      actionUrl: dto.actionUrl,
    );
  }
}
