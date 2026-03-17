import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:laqta/features/notifications/data/dtos/notification_dto.dart';

class BackendNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  BackendNotificationsRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<NotificationDto>> getNotifications(String userId) async {
    final response = await _apiClient.get('/notifications/me');
    final notifications =
        (response as Map<String, dynamic>)['notifications'] as List<dynamic>? ??
        <dynamic>[];
    return notifications
        .whereType<Map<String, dynamic>>()
        .map(NotificationDto.fromJson)
        .toList();
  }

  @override
  Future<void> createNotification(NotificationDto notification) async {
    await _apiClient.post(
      '/notifications',
      body: {
        'userId': notification.userId,
        'title': notification.title,
        'body': notification.body,
        'type': notification.type,
        'data': notification.data?.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      },
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) {
      return;
    }
    await _apiClient.patch(
      '/notifications/read-all',
      body: {'notificationIds': notificationIds},
    );
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete('/notifications/$notificationId');
  }
}
