import 'package:luqta/features/notifications/data/dtos/notification_dto.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationDto>> getNotifications(String userId);

  Future<void> createNotification(NotificationDto notification);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(List<String> notificationIds);

  Future<void> deleteNotification(String notificationId);
}
