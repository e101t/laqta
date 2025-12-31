import 'package:luqta/features/notifications/data/datasources/firestore_notifications_remote_data_source.dart';
import 'package:luqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:luqta/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:luqta/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:luqta/features/notifications/domain/usecases/delete_notification.dart';
import 'package:luqta/features/notifications/domain/usecases/get_notifications.dart';
import 'package:luqta/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:luqta/features/notifications/domain/usecases/mark_notification_read.dart';

class NotificationsDependencies {
  static final NotificationsRemoteDataSource _remoteDataSource =
      FirestoreNotificationsRemoteDataSource();
  static final NotificationsRepository _repository =
      NotificationsRepositoryImpl(_remoteDataSource);

  static GetNotifications getNotifications() => GetNotifications(_repository);

  static MarkNotificationRead markNotificationRead() =>
      MarkNotificationRead(_repository);

  static MarkAllNotificationsRead markAllNotificationsRead() =>
      MarkAllNotificationsRead(_repository);

  static DeleteNotification deleteNotification() =>
      DeleteNotification(_repository);
}
