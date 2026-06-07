import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:laqta/features/notifications/data/mappers/notification_mapper.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  const NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NotificationModel>>> getNotifications({
    required String userId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getNotifications(userId);
      final notifications = dtos.map(NotificationMapper.toDomain).toList();
      return Result.success(notifications);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load notifications'),
      );
    }
  }

  @override
  Future<Result<void>> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final dto = NotificationMapper.toDto(notification);
      await _remoteDataSource.createNotification(dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to create notification'),
      );
    }
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to mark notification as read'),
      );
    }
  }

  @override
  Future<Result<void>> markAllAsRead({
    required String userId,
    required List<String> notificationIds,
  }) async {
    try {
      await _remoteDataSource.markAllAsRead(notificationIds);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to mark all notifications as read'),
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to delete notification'),
      );
    }
  }
}
