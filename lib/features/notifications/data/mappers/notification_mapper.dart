import 'package:laqta/features/notifications/data/dtos/notification_dto.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';

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

  static NotificationDto toDto(NotificationModel model) {
    return NotificationDto(
      id: model.notificationId,
      userId: model.userId,
      title: model.title,
      body: model.body,
      type: model.type,
      data: model.data,
      isRead: model.isRead,
      createdAt: model.createdAt,
      imageUrl: model.imageUrl,
      actionUrl: model.actionUrl,
    );
  }
}
