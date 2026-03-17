import 'package:laqta/core/domain/result/result.dart';
import '../entities/notification_model.dart';

abstract class NotificationsRepository {
  Future<Result<List<NotificationModel>>> getNotifications({
    required String userId,
  });

  Future<Result<void>> createNotification(NotificationModel notification);

  Future<Result<void>> markAsRead(String notificationId);

  Future<Result<void>> markAllAsRead({
    required String userId,
    required List<String> notificationIds,
  });

  Future<Result<void>> deleteNotification(String notificationId);
}
